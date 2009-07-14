# -*- cperl -*-
package TrEd::Menu;

use strict;
use warnings;

sub new {
  my ($class,$menudata)=@_;
  my $self = bless {
    -menubars => {},
    -menudata => $menudata,
    -menu_lookup_hash => {},
  }, $class;
}

sub get_menubar {
  my ($self,$key)=@_;
  return $self->{-menubars}{$key};
}

sub create_menubar {
  my ($self, $parent, $key, $opts)=@_;
  $opts||={};
  my $menudata = $self->{-menudata};

  my $menubar = $parent->Menu(
    -type => 'menubar',
    -borderwidth => 2,
    -tearoff => 0,
    -takefocus=> 1,
    %{ $menudata->{$key}[2] || {} },
    %$opts,
    -menuitems => $self->build_menu( $menudata->{$key}[3], [$key])
   );
  return $self->{-menubars}{$key} = $menubar;
}

sub create_menu_frame {
  my ($self, $parent, $key, $opts)=@_;
  $opts||={};
  my $menudata = $self->{-menudata};
  my $menubar = $parent->Frame(
    -borderwidth=> 0,
    %{ $menudata->{$key}[2] || {} },
    %$opts,
   );
  my $m_items = $self->build_menu( $menudata->{$key}[3], [$key]);
  foreach my $m_item (@$m_items) {
    my $type = $m_item->[0];
    $m_item->[0]='-text';
    if ($type eq 'Cascade') {
      $menubar->Menubutton(@$m_item)->pack(qw/-side left/);
    } elsif ($type eq 'Button') {
      $menubar->Button(@$m_item)->pack(qw/-side left/);
    } elsif ($type eq 'Checkbutton') {
      $menubar->Checkbutton(@$m_item)->pack(qw/-side left/);
    }
  }
  return $self->{-menubars}{$key} = $menubar;
}


sub build_menu {
  my ($self,$menuitems,$parent_path)=@_;
  my $data = $self->{-menudata};
  my $lookup_hash = $self->{-menu_lookup_hash};
  my @ret;

  for my $key (@$menuitems) {
    # my @debug = (
    #   -command => [sub {
    # 		   my ($self,$lookup_hash,$key)=@_;
    # 		   my $label = get_menu_label($self,$key);
    # 		   my $accel = get_menu_accel($self,$key);
    # 		   set_menu_label($self, $key, $label.'+');
    # 		   set_menu_accel($self, $key, $accel.'+x');
    # 		 },$self,$lookup_hash,$key]
    #  );
    my $item = $data->{$key};
    my ($type, $label, $opts, $subitems)=@$item;
    my $path = [@$parent_path,$key];
    push @{$lookup_hash->{$key}||=[]}, $path;
    push @ret, [
      $type,
      $label,
      ($opts ? (%$opts
		  # , @debug
	       ) : ()),
      ($subitems ? (-menuitems => $self->build_menu($subitems, $path)) : ()),
     ];
  }
  return \@ret;
}

sub set_menu_label {
  my ($self,$key,$label)=@_;
  my $lookup_hash = $self->{-menu_lookup_hash};
  for my $m (lookup_menu_item($self,$key)) {
    $m->[0]->entryconfigure($m->[1],-label=>$label);
  }
  $self->{-menudata}{$key}[1]=$label;
}

sub get_menu_label {
  my ($self,$key)=@_;
  my $m = $self->{-menudata}{$key};
  return $m->[1] if $m;
  return;
}

sub get_menu_option {
  my ($self,$key,$opt)=@_;
  my $m = $self->{-menudata}{$key};
  return $m->[2]{$opt} if $m;
  return;
}

sub set_menu_options {
  my ($self,$key,%opt)=@_;
  if (exists ($opt{-label})) {
    my $value = delete $opt{-label};
    set_menu_label($self,$key,$value);
  }
  return unless keys %opt;
  my $lookup_hash = $self->{-menu_lookup_hash};
  for my $m (lookup_menu_item($self,$key)) {
    $m->[0]->entryconfigure($m->[1],%opt);
  }
  for my $k (keys %opt) {
    $self->{-menudata}{$key}[2]{$k}=$opt{$k};
  }
}


sub lookup_menu_item {
  my ($self,$key)=@_;
  my $hash = $self->{-menu_lookup_hash};
  if (exists($hash->{$key})) {
    my @ret;
    foreach my $path (@{$hash->{$key}}) {
      my @steps = map { $self->{-menudata}{$_}[1] } @$path;
      if (wantarray) {
	push @ret, [resolve_menu_path($self,\@steps)];
      } else {
	return resolve_menu_path($self,\@steps);
      }
    }
    return @ret;
  } else {
    warn "Didn't find menu item: $key\n";
  }
  return;
}

sub resolve_menu_path {
  my ($self,$steps)=@_;
  my ($toplevel_menu, @s) = @$steps;
  my $menu = $self->{-menubars}{ $toplevel_menu };
  my $end = wantarray ? 1 : 0;
  while (@s>$end) {
    $menu = $menu->entrycget(shift(@s), '-menu');
  }
  return $end ? ($menu, @s) : $menu
}

1;
