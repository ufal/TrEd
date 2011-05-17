# -*- cperl -*-
package TrEd::Menu;

use strict;
use warnings;
our $VERSION = '0.02';

use Data::Dumper;

use Readonly;

# structure imported from menu.inc into menudata
Readonly my $MENUITEM_TYPE => 0;
Readonly my $MENUITEM_LABEL => 1;
Readonly my $MENUITEM_OPTIONS => 2;
Readonly my $MENUITEM_SUBITEMS => 3;

#######################################################################################
# Usage         : TrEd::Menu->new($menudata_ref)
# Purpose       : Create TrEd's main menu
# Returns       : Blessed hash reference to created TrEd::Menu object
# Parameters    : hash_ref $menudata_ref -- reference to hash of menu items and callbacks
# Throws        : no exception
# Comments      : Hash of menu items and callbacks is stored in tredlib/TrEd/Menu/menu.inc
# See Also      : 
sub new {
  my ($class, $menudata) = @_;
  my $self = bless {
    -menubars => {},
    -menudata => $menudata,
    -menu_lookup_hash => {},
  }, $class;
  return $self;
}

#######################################################################################
# Usage         : $menu->get_menubar($key)
# Purpose       : Return menubar with name $key
# Returns       : Tk::Menu with key $key
# Parameters    : scalar $key -- name of the menubar
# Throws        : no exception
# Comments      : 
# See Also      : create_menubar()
sub get_menubar {
  my ($self, $key) = @_;
  return $self->{-menubars}{$key};
}

#######################################################################################
# Usage         : $menu->create_menubar($parent, $menubar_key, $opts_ref);
# Purpose       : Create menubar with its items on $parent and store it under name $key
# Returns       : Created Tk::Menubar
# Parameters    : Tk::Frame $parent   -- parent of menubar
#                 scalar $menubar_key -- name for the created menubar
#                 hash_ref $opts_ref  -- ref to hash of options
# Throws        : no exception
# Comments      : Key-value pairs in hash of options passed as $opts_ref are used as parameters
#                 when creating Tk::Menu. 
#                 Menudata hash item with key $key should contain reference to array. 
#                 Its third element is used for Tk::Menu options. 
#                 build_menu function is used to create menu items.
#                 This function is used for creating menu on platforms other than Win32 
#                 (Not sure why (yet)...)
# See Also      : create_menu_frame(), build_menu(),
sub create_menubar {
  my ($self, $parent, $key, $opts_ref) = @_;
  $opts_ref ||= {};
  my $menudata = $self->{-menudata};

  my $menubar = $parent->Menu(
    -type         => 'menubar',
    -borderwidth  => 2,
    -tearoff      => 0,
    -takefocus    => 1,
    %{ $menudata->{$key}[$MENUITEM_OPTIONS] || {} },
    %{$opts_ref},
    -menuitems    => $self->build_menu( $menudata->{$key}[$MENUITEM_SUBITEMS], [$key])
   );
  return $self->{-menubars}{$key} = $menubar;
}

#######################################################################################
# Usage         : $menu->create_menu_frame($parent, $key, $opts_ref)
# Purpose       : Create menu frame and build all the menus and submenus
# Returns       : Undef in scalar context, empty list in list context
# Parameters    : Tk::Frame $parent   -- parent of menubar
#                 scalar $key         -- name for the created menubar frame
#                 hash_ref $opts_ref  -- ref to hash of options
# Throws        : no exception
# Comments      : Key-value pairs in hash of options passed as $opts_ref are used as parameters
#                 when creating Tk::Frame for the menu. 
#                 Menudata hash item with key $key should contain reference to array. 
#                 Its third element is used for Tk::Frame menu options. 
#                 build_menu function is used to create menu items.
#                 This function is used for creating menu on Win32 platform. 
#                 (Not sure why (yet)...)
# See Also      : create_menubar(), build_menu()
sub create_menu_frame {
  my ($self, $parent, $key, $opts_ref) = @_;
  $opts_ref ||= {};
  my $menudata = $self->{-menudata};
  my $menubar = $parent->Frame(
    -borderwidth=> 0,
    %{ $menudata->{$key}[$MENUITEM_OPTIONS] || {} },
    %{$opts_ref},
   );
  
  my $m_items = $self->build_menu( $menudata->{$key}[$MENUITEM_SUBITEMS], [$key]);
  foreach my $m_item (@{$m_items}) {
    my $type = $m_item->[0];
    $m_item->[0] = '-text';
    if ($type eq 'Cascade') {
      $menubar->Menubutton(@{$m_item})->pack(qw/-side left/);
    } 
    elsif ($type eq 'Button') {
      $menubar->Button(@{$m_item})->pack(qw/-side left/);
    } 
    elsif ($type eq 'Checkbutton') {
      $menubar->Checkbutton(@{$m_item})->pack(qw/-side left/);
    }
  }
  return $self->{-menubars}{$key} = $menubar;
}

#######################################################################################
# Usage         : $menu->_create_menu_item($menuitem_ref, $path)
# Purpose       : Create menu item and fill it with data from $menuitem_ref 
# Returns       : Reference to array accepted by -menuitems option in Tk::Menu::Item, 
#                 i.e. [menu_type, menu_label, options, subitems]
# Parameters    : hash_ref $menuitem_ref  -- reference to array with information about menu item
#                 array_ref $path  -- path under which the menu item is created 
# Throws        : no exception
# Comments      : 
# See Also      : build_menu()
sub _create_menu_item {
  my ($self, $item_ref, $path) = @_;
  my ($type, $label, $opts_ref, $subitems) = @{$item_ref};
  
  # my @debug = (
  #   -command => [sub {
  # 		   my ($self,$lookup_hash,$key)=@_;
  # 		   my $label = get_menu_label($self,$key);
  # 		   my $accel = get_menu_accel($self,$key);
  # 		   set_menu_label($self, $key, $label.'+');
  # 		   set_menu_accel($self, $key, $accel.'+x');
  # 		 },$self,$lookup_hash,$key]
  #  );
  
  # Here we can not use $MENUITEM_OPTIONS and $MENUITEM_SUBITEMS, because
  # options hash creates more array elements
  my $menu_item = [];
  $menu_item->[$MENUITEM_TYPE] = $type;
  $menu_item->[$MENUITEM_LABEL] = $label;
  push @{$menu_item}, ($opts_ref  ? (%{$opts_ref}) # , @debug
                                  : ()
                       );
  push @{$menu_item}, ($subitems ?  (-menuitems => $self->build_menu($subitems, $path)) 
                                :   ()
                                );
  return $menu_item;
}

#######################################################################################
# Usage         : $menu->build_menu($menuitems_ref, $parent_path)
# Purpose       : Build menu and its submenus recursively 
# Returns       : Reference to array of references to array as it's accepted by -menuitems 
#                 option in Tk::Menu::Item, i.e. [menu_type, menu_label, options, subitems]
# Parameters    : hash_ref $menuitems_ref -- reference to hash of options
#                 array_ref $parent_path  -- parent's path in menu
# Throws        : no exception
# Comments      : For each item in @$menuitems_ref list look it up in menudata
#                 and add its type, label, options and subitems into the resulting array.
#                 Fills lookup menu hash with information from menudata.
# See Also      : create_menu_frame(), create_menubar()
sub build_menu {
  my ($self, $menuitems_ref, $parent_path) = @_;
  my $data = $self->{-menudata};
  my $lookup_hash = $self->{-menu_lookup_hash};
  my @ret;

  for my $key (@{$menuitems_ref}) {
    my $path = [@{$parent_path}, $key];
    push @{$lookup_hash->{$key} ||= []}, $path;
    
    my $item = $data->{$key};
    my ($type, $label, $opts, $subitems) = @{$item};
    push @ret, $self->_create_menu_item($data->{$key}, $path);
  }
  return \@ret;
}

#######################################################################################
# Usage         : $menu->set_menu_label($key, $label)
# Purpose       : Change label for menu item with key $key to $label
# Returns       : Undef/empty list
# Parameters    : scalar $key   -- menu item identification
#                 scalar $label -- new label for the menu item
# Throws        : no exception
# Comments      : Modifies the menu item and also the menudata hash.
# See Also      : get_menu_label()
sub set_menu_label {
  my ($self, $key, $label) = @_;
  foreach my $menu_item (lookup_menu_item($self, $key)) {
    $menu_item->[$MENUITEM_TYPE]->entryconfigure($menu_item->[$MENUITEM_LABEL], -label => $label);
  }
  $self->{-menudata}{$key}[$MENUITEM_LABEL] = $label;
  return;
}

#######################################################################################
# Usage         : $menu->get_menu_label($key)
# Purpose       : Get the label for menu item with key $key
# Returns       : Menu label if it exists, undef/empty list otherwise.
# Parameters    : scalar $key -- menu item identification
# Throws        : no exception
# Comments      :
# See Also      : set_menu_label()
sub get_menu_label {
  my ($self, $key) = @_;
  my $menu_item = $self->{-menudata}{$key};
  return $menu_item->[$MENUITEM_LABEL] if $menu_item;
  return;
}

#######################################################################################
# Usage         : $menu->get_menu_option($key, $option_name)
# Purpose       : Get current value of option $option_name for menu item with key $key
# Returns       : Value of specified option 
#                 or undef/empty list if the option is not defined
# Parameters    : scalar $key         -- menu item identification
#                 scalar $option_name -- name of the option whose value we want to find out
# Throws        : no exception
# Comments      :
# See Also      : set_menu_options()
sub get_menu_option {
  my ($self, $key, $option_name) = @_;
  my $menu_item = $self->{-menudata}{$key};
  return $menu_item->[$MENUITEM_OPTIONS]{$option_name} if $menu_item;
  return;
}

#######################################################################################
# Usage         : $menu->set_menu_options($key, %opt)
# Purpose       : Set options for menu item with key $key
# Returns       : Undef/empty list in scalar/list context
# Parameters    : scalar $key -- menu item identification
#                 hash %opt   -- hash of options for menu item
# Throws        : no exception
# Comments      :
# See Also      : get_menu_option()
sub set_menu_options {
  my ($self, $key, %opt) = @_;
  if (exists ($opt{-label})) {
    my $value = delete $opt{-label};
    $self->set_menu_label($key, $value);
  }
  return if not keys %opt;
  
  for my $menu_item ($self->lookup_menu_item($key)) {
    $menu_item->[$MENUITEM_TYPE]->entryconfigure($menu_item->[$MENUITEM_LABEL], %opt);
  }
  for my $opt_name (keys %opt) {
    $self->{-menudata}{$key}[$MENUITEM_OPTIONS]{$opt_name} = $opt{$opt_name};
  }
  return;
}

#######################################################################################
# Usage         : $menu->lookup_menu_item($key)
# Purpose       : Find menu item with key $key in menu lookup hash
# Returns       : In scalar context the corresponding menu for the first path in lookup hash
#                 is returned. In array context, list of references to the corresponding
#                 menus for all the paths from lookup hash are returned
# Parameters    : scalar $key -- key / name of the menu item
# Throws        : Carps if menu item was not found.
# Comments      : 
# See Also      : resolve_menu_path()
sub lookup_menu_item {
  my ($self, $key) = @_;
  my $hash = $self->{-menu_lookup_hash};
  if (exists($hash->{$key})) {
    my @ret;
    foreach my $path (@{$hash->{$key}}) {
      my @steps = map { $self->{-menudata}{$_}[$MENUITEM_LABEL] } @{$path};
      if (wantarray) {
        push @ret, [$self->resolve_menu_path(\@steps)];
      } 
      else {
        return $self->resolve_menu_path(\@steps);
      }
    }
    return @ret;
  }
  else {
    carp("Didn't find menu item: $key\n");
  }
  return;
}

#######################################################################################
# Usage         : $menu->resolve_menu_path($steps_ref)
# Purpose       : Find the last menu item on the path supplied by @$steps_ref
# Returns       : In array contex, function returns a list whose first element is menu 
#                 which contains the last item in subpath from @$steps_ref, other elements 
#                 are the remaining items from @$steps_ref. 
#                 In scalar context just the menu which contains the last item in subpath 
#                 from @$steps_ref is returned.
# Parameters    : array_ref $steps_ref -- array containing toplevel menu and path through submenus
# Throws        : no exception
# Comments      : 
# See Also      : 
sub resolve_menu_path {
  my ($self, $steps_ref) = @_;
  my ($toplevel_menu, @submenus) = @{$steps_ref};
  my $menu = $self->{-menubars}{ $toplevel_menu };

  my $end = wantarray ? 1 : 0;
  while (@submenus > $end) {
    my $item = shift @submenus;
    if ($menu) {
      ($menu) = $menu->isa('Tk::Menu') 
              ? $menu->entrycget($item, '-menu') 
              : (map { $_->cget('-menu') } 
                  grep { $_->isa('Tk::Menubutton') and $_->cget('-text') eq $item } 
                  $menu->children()
                 );
    }
  }
  return $end ? ($menu, @submenus) : $menu
}

1;

__END__


=head1 NAME


TrEd::Menu - Creating and updating menu for TrEd application


=head1 VERSION

This documentation refers to 
TrEd::Menu version 0.2.


=head1 SYNOPSIS

  use TrEd::Menu;
  
  my $main_menu = TrEd::Menu->new(_load_menus(\%tred));
  
  my $menubar;
  my $key = 'MENUBAR';
  if ($^O eq 'MSWin32') {
    $menubar = $main_menu->create_menu_frame($top, $key, { -relief=> $menubarRelief });
  } else {
    $menubar = $main_menu->create_menubar($top->Frame(), $key, { -relief=> $menubarRelief });
  }
  
  $menubar = 'something else';
  $menubar = $main_menu->get_menubar($key);
  
  my $subitems = [
                  'MENUBAR:FILE',
                  'MENUBAR:NODE',
                  'MENUBAR:TREE',
                  'MENUBAR:VIEW',
                  'MENUBAR:MACROS',
                  'MENUBAR:SETUP',
                  'MENUBAR:HELP'
                 ];
  
  $main_menu->build_menu( $subitems, [$key])

  my $label = $main_menu->get_menu_label($key);
  $main_menu->set_menu_label($key, 'NEW_LABEL');
  
  $main_menu->get_menu_option($key, '-accelerator');
  $main_menu->set_menu_options($key, -accelerator => 'accelerator1');
  
  my $path = 'MENUBAR:HELP:EXTENSION_MANUALS';
  $main_menu->lookup_menu_item($path);
  
  my @steps = (
    'MENUBAR',
    'File',
    'File Lists',
  )
  $main_menu->resolve_menu_path(\@steps);
  

=head1 DESCRIPTION

This package contains a handful of funcitions to create and manipulate main menu in TrEd application. 
It allows editing menu items -- their labels and options and simple menu item lookup.

=head1 SUBROUTINES/METHODS

=over 4 



=item * C<TrEd::Menu->new($menudata_ref)>

=over 6

=item Purpose

Create TrEd's main menu

=item Parameters

  C<$menudata_ref> -- hash_ref $menudata_ref -- reference to hash of menu items and callbacks

=item Comments

Hash of menu items and callbacks is stored in tredlib/TrEd/Menu/menu.inc


=item Returns

Blessed hash reference to created TrEd::Menu object

=back


=item * C<$menu->get_menubar($key)>

=over 6

=item Purpose

Return menubar with name $key

=item Parameters

  C<$key> -- scalar $key -- name of the menubar


=item See Also

L<create_menubar>,

=item Returns

Tk::Menu with key $key

=back


=item * C<$menu->create_menubar($parent, $menubar_key, $opts_ref);>

=over 6

=item Purpose

Create menubar with its items on $parent and store it under name $key

=item Parameters

  C<$parent> -- Tk::Frame $parent   -- parent of menubar
  C<$menubar_key> -- scalar $menubar_key -- name for the created menubar
  C<$opts_ref> -- hash_ref $opts_ref  -- ref to hash of options

=item Comments

Key-value pairs in hash of options passed as $opts_ref are used as parameters
when creating Tk::Menu. 
Menudata hash item with key $key should contain reference to array. 
Its third element is used for Tk::Menu options. 
build_menu function is used to create menu items.
This function is used for creating menu on platforms other than Win32 
(Not sure why (yet)...)

=item See Also

L<create_menu_frame>,
L<build_menu>,

=item Returns

Created Tk::Menubar

=back


=item * C<$menu->create_menu_frame($parent, $key, $opts_ref)>

=over 6

=item Purpose

Create menu frame and build all the menus and submenus

=item Parameters

  C<$parent> -- Tk::Frame $parent   -- parent of menubar
  C<$key> -- scalar $key         -- name for the created menubar frame
  C<$opts_ref> -- hash_ref $opts_ref  -- ref to hash of options

=item Comments

Key-value pairs in hash of options passed as $opts_ref are used as parameters
when creating Tk::Frame for the menu. 
Menudata hash item with key $key should contain reference to array. 
Its third element is used for Tk::Frame menu options. 
build_menu function is used to create menu items.
This function is used for creating menu on Win32 platform. 
(Not sure why (yet)...)

=item See Also

L<create_menubar>,
L<build_menu>,

=item Returns

Undef in scalar context, empty list in list context

=back


=item * C<$menu->_create_menu_item($menuitem_ref, $path)>

=over 6

=item Purpose

Create menu item and fill it with data from $menuitem_ref 

=item Parameters

  C<$menuitem_ref> -- hash_ref $menuitem_ref  -- reference to array with information about menu item
  C<$path> -- array_ref $path  -- path under which the menu item is created 


=item See Also

L<build_menu>,

=item Returns

Reference to array accepted by -menuitems option in Tk::Menu::Item, 
i.e. [menu_type, menu_label, options, subitems]

=back


=item * C<$menu->build_menu($menuitems_ref, $parent_path)>

=over 6

=item Purpose

Build menu and its submenus recursively 

=item Parameters

  C<$menuitems_ref> -- hash_ref $menuitems_ref -- reference to hash of options
  C<$parent_path> -- array_ref $parent_path  -- parent's path in menu

=item Comments

For each item in @$menuitems_ref list look it up in menudata
and add its type, label, options and subitems into the resulting array.
Fills lookup menu hash with information from menudata.

=item See Also

L<create_menu_frame>,
L<create_menubar>,

=item Returns

Reference to array of references to array as it's accepted by -menuitems 
option in Tk::Menu::Item, i.e. [menu_type, menu_label, options, subitems]

=back


=item * C<$menu->set_menu_label($key, $label)>

=over 6

=item Purpose

Change label for menu item with key $key to $label

=item Parameters

  C<$key> -- scalar $key   -- menu item identification
  C<$label> -- scalar $label -- new label for the menu item

=item Comments

Modifies the menu item and also the menudata hash.

=item See Also

L<get_menu_label>,

=item Returns

Undef/empty list

=back


=item * C<$menu->get_menu_label($key)>

=over 6

=item Purpose

Get the label for menu item with key $key

=item Parameters

  C<$key> -- scalar $key -- menu item identification


=item See Also

L<set_menu_label>,

=item Returns

Menu label if it exists, undef/empty list otherwise.

=back


=item * C<$menu->get_menu_option($key, $option_name)>

=over 6

=item Purpose

Get current value of option $option_name for menu item with key $key

=item Parameters

  C<$key> -- scalar $key         -- menu item identification
  C<$option_name> -- scalar $option_name -- name of the option whose value we want to find out


=item See Also

L<set_menu_options>,

=item Returns

Value of specified option 
or undef/empty list if the option is not defined

=back


=item * C<$menu->set_menu_options($key, %opt)>

=over 6

=item Purpose

Set options for menu item with key $key

=item Parameters

  C<$key> -- scalar $key -- menu item identification
  C<%opt> -- hash %opt   -- hash of options for menu item


=item See Also

L<get_menu_option>,

=item Returns

Undef/empty list in scalar/list context

=back


=item * C<$menu->lookup_menu_item($key)>

=over 6

=item Purpose

Find menu item with key $key in menu lookup hash

=item Parameters

  C<$key> -- scalar $key -- key / name of the menu item


=item See Also

L<resolve_menu_path>,

=item Returns

In scalar context the corresponding menu for the first path in lookup hash
is returned. In array context, list of references to the corresponding
menus for all the paths from lookup hash are returned

=back


=item * C<$menu->resolve_menu_path($steps_ref)>

=over 6

=item Purpose

Find the last menu item on the path supplied by @$steps_ref

=item Parameters

  C<$steps_ref> -- array_ref $steps_ref -- array containing toplevel menu and path through submenus



=item Returns

In array contex, function returns a list whose first element is menu 
which contains the last item in subpath from @$steps_ref, other elements 
are the remaining items from @$steps_ref. 
In scalar context just the menu which contains the last item in subpath 
from @$steps_ref is returned.

=back





=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

Readonly

=head1 INCOMPATIBILITIES


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

Copyright (c) 
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
