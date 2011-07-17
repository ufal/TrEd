package TrEd::SidePanel;

# pajas@ufal.mff.cuni.cz          15 dub 2008


use strict;
use warnings;
use Carp;
use Tk::Adjuster;
use Scalar::Util qw(blessed);

use TrEd::Config;
use TrEd::SidePanel::Widget;
use TrEd::Bookmarks;
use TrEd::File;

our $VERSION = '0.02';

sub new {
  my ($class, $parent, $opts) = @_;
  $opts||={};
  if (not (ref($parent) and (blessed($parent) and $parent->isa('Tk::Widget')))) {
    croak("Usage: ".__PACKAGE__."->new(\$parent_widget)");
  }
  return bless {
    %{$opts},
    frame => $parent->Frame(),
    widget_names => [],
    widgets => {},
  }, $class;
}

sub widget_names {
  my ($self)=@_;
  return @{$self->{widget_names}};
}

sub widgets {
  my ($self)=@_;
  my $widgets = $self->{widgets};
  return map {$widgets->{$_}} @{$self->{widget_names}};
}

sub widget {
  my ($self, $name)=@_;
  return $self->{widgets}{$name};
}

sub frame {
  my ($self)=@_;
  return $self->{frame};
}

sub add {
  my ($self,$name,$tk_widget,$opts) =@_;
  croak(__PACKAGE__."->add: item named '$name' already exists") if $self->widget($name);
  $opts||={};
  my $before = delete $opts->{-before};
  my $after = delete $opts->{-after};
  if (defined($after) and defined($before)) {
    croak(__PACKAGE__."->add: use either -after or -before, not both");
  }

  $opts->{-label}||=$name;
  $opts->{name}=$name;
  $opts->{panel} = $self;

  my $w = TrEd::SidePanel::Widget->new($tk_widget,$opts);
  if (defined($after) or defined($before)) {
    my $ref = defined($after) ? $after : $before;
    croak(__PACKAGE__."->add: item named '$ref' not found") unless $self->widget($ref);
    @{$self->{widget_names}} = map { $_ eq $ref ? ( defined($after) ? ($_,$name) : ($name,$_) ) : $_ } @{$self->{widget_names}};
  } else {
    push @{$self->{widget_names}}, $name;
  }
  $self->{widgets}{$name}=$w;
  return $w;
}

sub remove {
  my ($self, $name) =@_;
  @{$self->{widget_names}} = grep { $_ ne $name } @{$self->{widget_names}};
  return delete $self->{widgets}{$name};
}

sub is_shown {
  my ($self, $name)=@_;
  my $w=$self->{widgets}{$name};
  return unless $w;
  return $w->is_shown;
}

sub equalize_sizes {
  my ($self)=@_;
  my @shown = grep { $_->is_shown } $self->widgets;
  return unless @shown;
  my $height = $self->frame->height;
  $height -= $_->button->height for $self->widgets;
  $height=0 if $height<0;
  my $equal_size = $height/@shown;
  for my $w (@shown) {
    next unless $w->adjuster_packed;
    $w->adjuster->delta_height($equal_size-$w->height)
  }
}



sub update_attribute_view {
  my ($grp,$win) = main::grp_win($_[0]);
  my $view = $grp->{sidePanel} && $grp->{sidePanel}->widget('attrsView');
  return unless $view and $view->is_shown;
  my $attrsView=$view->data;
  return unless ref $attrsView;
  my $current = $win->{currentNode};
  $attrsView->set_option('no_sort'=>!$TrEd::Config::sortAttrs);
  $attrsView->set_option('no_value_sort'=>!$TrEd::Config::sortAttrValues);
  $attrsView->set_data({
    type => ref($current) && $current->type,
    object => $current,
  });
}

# attrView, UI
sub toggle_attribute_view_hide_empty {
  my ($self, $grp)=@_;
  my $view = $self && $self->widget('attrsView');
  return unless $view and $view->is_shown();
  my $attrsView=$view->data();
  return unless ref $attrsView;
  $attrsView->{userdata}{hide_empty}=!$attrsView->{userdata}{hide_empty};
  update_attribute_view($grp->{focusedWindow});
}

sub init_node_attributes {
  my ($self, $grp) = @_;
  my $colf = $grp->{sidePanelFrame}->Frame(
    -relief => 'sunken',
    -borderwidth => 1,
   );
  my $cb = $colf->Checkbutton(
    -text => 'Hide empty values',
    -font => 'C_small',
    -underline => 2,
    -relief => 'flat',
    -anchor=>'nw',
    -justify => 'left',
-command => sub {
  if ($grp->{attrsViewPacked} and $grp->{sidePanelPacked}) {
    update_attribute_view($grp->{focusedWindow});
  }
})->pack(-side=>'top',-fill=>'x');
  $grp->{top}->bind('my',"<Alt-d>", [sub{
				   my ($w,$grp)=@_;
				   if (defined(evalMacro($w,$grp,'ALT+'))) {
				     Tk->break;
				   } else {
				     $self->toggle_attribute_view_hide_empty($grp);
				     Tk->break;
				   }
				 },$grp]);
  my $attrsView = $colf->TrEdNodeEditDlg({
    object=>undef,
    dialog => $colf,
    no_show=>1,
    no_sort=>!$TrEd::Config::sortAttrs,
    no_value_sort=>!$TrEd::Config::sortAttrValues,
    search_field => 0,
    hide_empty => 1,
    knit_support => 1,
    side_panel_wrap => $TrEd::Config::sidePanelWrap,
    TrEdNodeEdit=>{
-takefocus=>0,
-font => 'C_small',
-borderwidth => 1,
-selectborderwidth=>1,
-scrollbars=>'soe',
-itemstyle => {
  -pady=>1,
  -padx=>1,
},
-colors => {
  bg => '#efefef',
  constant => 'white',
},
    },
    enable_callback => sub{ 0 },
    attribute_sort_callback => [ sub {
			     my ($grp,$array)=@_;
			     return main::doEvalHook($grp->{focusedWindow},'sort_attrs_hook',$array,'',$grp->{focusedWindow}{currentNode});
			   }, $grp ],
    no_focus => 1,
  });
  
  $attrsView->Subwidget('xscrollbar')->configure(qw(-borderwidth 1 -width 10));
  #TODO: this is experimental... just to try how to change scrollbar appearance
  #$attrsView->Subwidget('yscrollbar')->configure(qw(-background green));
  
  $cb->configure(-variable => \$attrsView->Subwidget('scrolled')->{userdata}{hide_empty});
  $grp->{sidePanel}->add('attrsView', $colf, { -label => 'Node Attributes',
					 -data => $attrsView->Subwidget('scrolled'),
					 -show_command => sub {
					   update_attribute_view($grp->{focusedWindow});
					  }
				       });
  $grp->{sidePanel}->widget('attrsView')->show;
}

sub init_browse_filesystem {
  my ($self, $grp) = @_;
  my $show_hidden=0;
  my $colf = $grp->{sidePanelFrame}->Frame(
    -relief => 'sunken',
    -borderwidth => 1,
   );
  my $fsel= $colf->MyFileSelect(-selectmode=> 'extended',
			  -takefocus => 1,
			  -font => 'C_small',
			  -filetypes=> \@TrEd::Config::open_types)
    ->pack(qw/-expand yes -fill both -side top/);
   $fsel->Subwidget('filelist')->configure(-background => 'white', -takefocus=>0);
  my $open_callback = [sub {
		   shift if @_>2;
		   my ($grp,$fsel)=@_;
		   return if $fsel->ChDir();
		   my ($file) = $fsel->getSelectedFiles(); # from Tk::MyFileSelect
		   if (defined($file) and length($file)) {
		     TrEd::File::openStandaloneFile($grp,$file);
		   }
		 },$grp,$fsel];
  $fsel->Subwidget('filelist')->bind('<Double-1>',$open_callback);
  my $menu = $fsel->Menu(
    -tearoff => 0,
    -menuitems => [
['Button' => '~Open',
 -command => $open_callback,
],
['Button' => '~Add To Filelist',
 -command => [sub {
   my ($grp,$fsel)=@_;
   my @files = grep { defined && length} $fsel->getSelectedFiles;
   TrEd::ManageFilelists::insertToFilelist($grp->{focusedWindow}, undef,undef, @files) if @files;
 },$grp,$fsel]
],
['Checkbutton' => '~Show hidden files',
 -variable => \$show_hidden,
 -command => [sub {
   my ($grp,$fsel)=@_;
   $fsel->configure(-showhidden=>$show_hidden);
   $fsel->ReadDir($fsel->getCWD);
 },$grp,$fsel]
],
['Cascade' => '~Filter',
 -tearoff => 0,
 -menuitems => [
   map {
     [ Button => $_->[0],
       -command => [
	 sub {
	   my ($fsel,$filter)=@_;
	   $fsel->SetFilter('',$filter);
	 },$fsel,(ref($_->[1]) ? join(' ',@{$_->[1]}) : $_->[1])
	],
      ]
   } @TrEd::Config::open_types
 ]
],
    ]
  );
  $fsel->Subwidget('filelist')->bind('<3>', sub { my ($w)=@_; $menu->Post($w->pointerxy); Tk->break; });
  $grp->{sidePanel}->add('fileSystemView', $colf, {
    -label => 'Browse File System',
    -data => $fsel,
    -show_command => sub {
    }
  });
}



sub init_filelist_view {
  my ($self, $grp) = @_;
  my $colf = $grp->{sidePanelFrame}->Frame(
      -relief => 'sunken',
      -borderwidth => 1,
     );
    my $t= $colf->Scrolled(qw/HList
			      -relief flat
			      -borderwidth 1
                              -selectborderwidth 1
			      -selectmode extended
			      -takefocus 0
			      -scrollbars soe/,
			      -separator=> "\t"
			     )
      ->pack(qw/-expand yes -fill both -side top/);
    my $hl = $t->Subwidget('scrolled');
    $hl->{balloonmsg} = '';
    $grp->{Balloon}->attach($hl,-msg => \$hl->{balloonmsg},
			    -initwait => 200,
			    -postcommand => sub {
			      my $w=shift;
			      my $y=$w->XEvent->y;
			      my $path = $w->nearest($y);
			      if (defined($path) and length($path)
				    and $w->infoExists($path)) {
				my @bbox = $w->infoBbox($path);
				if ($bbox[1]<$y and $y<$bbox[3]) {
				  $hl->{balloonmsg}=$w->infoData($path);
				  return 1;
				} else {
				  $hl->{balloonmsg}='';
				  return;
				}
			      }
			    }
			   );
    $hl->{default_style_imagetext}=$hl->ItemStyle(
      'imagetext',
      -padx=>1,
      -pady=>1,
      -foreground => 'black',
      -font => 'C_small',
     );
    $hl->{focused_style_imagetext}=$hl->ItemStyle(
      'imagetext',
      -padx=>1,
      -pady=>1,
      -foreground => 'blue',
      -selectforeground => 'blue',
      -font => 'C_small',
     );
    main::disable_scrollbar_focus($t);
    $t->BindMouseWheelVert();
    $grp->{sidePanel}->add('filelistView', $colf, {
      -label => 'Current File List',
      -data => $t,
      -show_command => sub {
	TrEd::Filelist::View::update($grp,$grp->{focusedWindow}{currentFilelist},1);
      }
     });
    my $open_callback = sub {
      my ($w,$grp)=@_;
      my $win = $grp->{focusedWindow};
      my $anchor=$w->info('anchor');
      my $nextentry=$w->info('next',$anchor);
      my $data=$w->info('data',$anchor);
      my $nextentry_parent;
      if (defined $nextentry) {
        $nextentry_parent = $w->info('parent',$nextentry);
      }
      unless ($nextentry && $nextentry_parent && $nextentry_parent eq $anchor) {
	# file -> go to
	$win->{currentFilelist}->set_current($data);
	my $pos = $win->{currentFilelist}->position;
	if ($pos>=0) {
	  main::gotoFile($win,$pos);
	}
      }
    };
    $t->bind('<Double-1>'=> [$open_callback, $grp]);
    my $menu = $t->Menu(
      -tearoff => 0,
      -menuitems => [
	['Button' => '~Open selected',
	 -command => [$open_callback,$t,$grp],
	],
	['Button' => '~Remove from filelist',
	 -command => [sub {
			my ($t,$grp)=@_;
			my $anchor=$t->info('anchor');
			my $fl =$grp->{focusedWindow}{currentFilelist};
			TrEd::ManageFilelists::removeFromFilelist($grp,
					   $fl,
					   TrEd::Dialog::Filelist::getFilelistLinePosition($fl, $anchor), $t->info('selection'));
			TrEd::Bookmarks::update_bookmarks($grp) if (ref($fl) and $fl->name eq $TrEd::Bookmarks::FILELIST_NAME);
		      },$t,$grp],
	],
      ]);
    $grp->{Balloon}->attach($menu,-msg => '');
    $t->bind('<3>', sub { my ($w)=@_;
			  $menu->Post($w->pointerxy);
			  Tk->break;
			});
    #$grp->{sidePanel}->widget('filelistView')->show;
}

sub init_macro_list {
  my ($self, $grp) = @_;
  my $colf = $grp->{sidePanelFrame}->Frame(
    -relief => 'sunken',
    -borderwidth => 1,
   );
  my $hl = TrEd::List::Macros::create_list($grp,$colf,\$grp->{focusedWindow}{macroContext},
		     { -padx=>1,
		       -pady=>1,
		       -foreground => 'black',
		       -font => 'C_small',
		     }
		    )
    ->pack(qw/-expand yes -fill both -side top/);
  $hl->configure(-takefocus=>0);
  $grp->{macroListViewOrder}=$grp->{macroListOrder};
  my $menu = $hl->Menu(
    -tearoff => 0,
    -menuitems => [
['Button' => 'Run selected macro',
 -command => [sub {
		my ($grp,$t)=@_;
		my $anchor = $t->info('anchor');
		return unless $anchor;
		my $macro=$t->info(data => $anchor);
		main::doEvalMacro($grp->{focusedWindow},$macro) if defined $macro;
	      },$grp,$hl],
],
['Checkbutton' => '~Swap Key/Name',
 -variable => \$grp->{macroListViewSwap},
 -command => [\&TrEd::List::Macros::update_view,$grp],
],
['Checkbutton' => 'See ~Perl names',
 -variable => \$grp->{macroListViewCalls},
 -command => [\&TrEd::List::Macros::update_view,$grp],
],
['Checkbutton' => 'Include ~Anonymous Macros',
 -variable => \$grp->{macroListViewAnonymous},
 -command => [\&TrEd::List::Macros::update_view,$grp],
],
['Cascade' => '~Sort By',
 -tearoff => 0,
 -menuitems => [
   map {
   [ Radiobutton => $_->[0],
     -variable => \$grp->{macroListViewOrder},
     -value => $_->[1],
     -command => [\&TrEd::List::Macros::update_view,$grp],
   ]} (['~Key','K'],['~Name','M'],['~Perl name','P'])
  ]
],
    ]
  );
  $hl->bind('<3>', sub { my ($w)=@_; $menu->Post($w->pointerxy); Tk->break; });

  $grp->{sidePanel}->add('macroListView', $colf, {
    -label => 'List of Macros',
    -data => $hl,
    -show_command => [\&TrEd::List::Macros::update_view,$grp],
  });
}

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

TrEd::SidePanel - Perl extension for blah blah blah

=head1 SYNOPSIS

   use TrEd::SidePanel;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for TrEd::SidePanel, 
created by template.el.

It looks like the author of the extension was negligent
enough to leave the stub unedited.

Blah blah blah.

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

Copyright (C) 2008 by Petr Pajas

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

