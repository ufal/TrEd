package TrEd::Menu::Macro;

use strict;
use warnings;

use TrEd::Config qw{$tredDebug $maxMenuLines};
use TrEd::Macros qw{};
use TrEd::MinMax qw{max2 min};

my %macro_menu_items = ();



sub user_menu_create_button {
    my ($label, $context, $macro_to_key_ref, $grp) = @_;
# my $label = $_;
 my $v = $TrEd::Macros::menuBindings{$context}->{$label};
 my $key = defined($v->[1]) ? $v->[1] : $macro_to_key_ref->{$v->[0]};
 $label=~s/^_+//;
 return [Button=> $label,
  -command=> [sub {
	    main::doEvalMacro($_[0]->{focusedWindow},
			$_[1]);
	  },
	  $grp,
	  $v->[0]],
  $key ? (-accelerator=> "(".$key.")") : ()];
}

sub cascadeMenus {
  $maxMenuLines=TrEd::MinMax::max2($maxMenuLines,3);
  my $uM=[ @_[0..TrEd::MinMax::min($maxMenuLines-1,$#_)] ];
  my $uuM=$uM;
  my $i=$maxMenuLines;
  while ($i<=$#_) {
    my $m = [@_[$i..TrEd::MinMax::min($i+$maxMenuLines-1,$#_)]];
    push @$uuM,[Cascade=> 'More...', -menuitems=> $m];
    $uuM=$m;
    $i+=$maxMenuLines;
  }
  return $uM;
}

sub update_user_menu {
    my ($grp) = @_;
    if ($grp->{UserMenu}) {
    my $menu = $grp->{UserMenu};
    $menu->delete(0,'end');
    $_->destroy for $menu->children;
    my $current;
    %macro_menu_items = (); # cache menus
    foreach my $context ("TredMacro",grep { $_ ne "TredMacro" } sort(keys(%TrEd::Macros::menuBindings))) {
      my %bindings_for_context = %{ $TrEd::Macros::keyBindings{$context} || {} };
      my %macro_to_key;
      # some keys may be bound to undef, filter these out
      foreach my $key_combination (keys %bindings_for_context) {
          if ( defined $bindings_for_context{$key_combination} ){
              $macro_to_key{$bindings_for_context{$key_combination}} = $key_combination;
          }
      }
      my $cascade = $menu->Cascade( -label => $context,
		 -menuitems=>
		   $macro_menu_items{$context}=cascadeMenus(
    		   map { user_menu_create_button($_, $context, \%macro_to_key, $grp) }
               grep { $context ne 'TredMacro' || !/^_*\*/ } # skip "Star Tools" bindings
    		   map { $_->[1] } 
    		   TrEd::MinMax::underscore_sort(
    		     map { [$_,$_] } keys %{$TrEd::Macros::menuBindings{$context}}
    		   )
		   )
				  );
      $current = $cascade if $context eq $grp->{focusedWindow}{macroContext}
    }
    # $tools_menu->entryconfigure('Current Context*',-menu => $current->menu);
  }
}

sub update_tools_menu {
    my ($grp) = @_;
    my $tools_menu = $grp->{ToolsMenu}; #->menu;
  if ($tools_menu) {
    # update "Star Tools" in the Tools menu
    print STDERR "updating toolmenu\n" if $tredDebug;
    my $end = $tools_menu->index('end');
    my ($first,$last);
    for (my $i=0; $i<$end; $i++) {
      if ($tools_menu->type($i) eq 'command' and $tools_menu->entrycget($i,'-label') =~ /^\*/) {
	$first = $i unless defined $first;
	$last = $i;
      } elsif (defined $first) {
	last;
      }
    }
    # print STDERR "clearing toolmenu from $first to $last\n" if defined($first) and $tredDebug;
    $tools_menu->delete($first,$last) if (defined $first);
    my $TredMacroMenu = $TrEd::Macros::menuBindings{TredMacro};
    my %macro_to_key = reverse %{ $TrEd::Macros::keyBindings{TredMacro}||{} };
    $first ||= 'end';
    foreach my $item (map $_->[1], TrEd::MinMax::underscore_sort(map [$_,$_], grep /^_*\*/, keys %{$TredMacroMenu})) {
      my $v = $TredMacroMenu->{$item};
      my $key = defined($v->[1]) ? $v->[1] : $macro_to_key{$v->[0]};
      my $label = $item; $label=~s/^_+//;
      # print STDERR "appending toolmenu $first\n" if $tredDebug;
      $tools_menu->insert($first,
			  'command',
			  -label => $label,
			  -command=> [sub { main::doEvalMacro($_[0]->{focusedWindow}, $_[1]); },
				      $grp,
				      $v->[0]],
			  $key ? (-accelerator=> "(".$key.")") : ());
      $first ++;
    }
    }
}
  
# context, menu, UI
# sub updateCurrentContextMenu
sub updateCurrentContextMenu {
  my ($grp)=@_;
  print STDERR "updating context menu\n" if $tredDebug;
  my $context = $grp->{focusedWindow}{macroContext};
  my $menu = $grp->{CurrentContextMacroMenu};
  eval {
    # if ($M->isa('Tk::Menubutton')) {
    #   $M->configure(-text => "$context");
    # } else {
    #   $M->configure(-label => "$context");
    # }
    # my $menu = $M->menu;
    $menu->delete(0,'end');
    $_->destroy for $menu->children;
    if (defined $context && $TrEd::Macros::menuBindings{$context}) {
#      $M->configure(-state=>'normal');
      $menu->AddItems(@{$macro_menu_items{$context}});
    } else {
#      $M->configure(-state=>'disabled');
    }
  };
  warn $@ if $@;
}

sub macro_menu_create_button {
    my ($context, $key_binding, $grp) = @_;
     $TrEd::Macros::keyBindings{$context}->{$key_binding}=~/(?:$context\-\>)?(.*)/;
	   return [Button => $1,
	    -command=> [sub {
			  main::doEvalMacro($_[0]->{focusedWindow},
				      $_[1]);
		   },$grp,
			$TrEd::Macros::keyBindings{$context}->{$key_binding}],
	    -accelerator=> "($_)"
	   ];
}

# macro, menu, UI
sub update_macro_menus {
  my ($grp)=@_;
  
  # update contexts menu
  $grp->{ContextsMenu}->update_context_list($grp);
  
  if ($grp->{MacroMenu}) {
    my $menu = $grp->{MacroMenu}->menu();
    foreach my $context (sort(keys(%TrEd::Macros::keyBindings))) {
      $menu->Cascade( -label => $context,
		      -menuitems=>
			cascadeMenus(map {
			    macro_menu_create_button($context, $_, $grp)
					 } sort(keys(%{$TrEd::Macros::keyBindings{$context}}))));
    }
  }
  
  update_user_menu($grp);
  
  update_tools_menu($grp);
  
  updateCurrentContextMenu($grp);
}


1;