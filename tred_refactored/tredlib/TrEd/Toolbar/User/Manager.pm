package TrEd::Toolbar::User::Manager;

use strict;
use warnings;

use Carp;

use TrEd::Toolbar::User;

my %user_toolbars = ();

#sub user_toolbars {
#    return keys %user_toolbars;
#}
#
#sub get_user_toolbar {
#    my ($toolbar_name) = @_;
#    return exists $user_toolbars{$toolbar_name} ? $user_toolbars{$toolbar_name} : ();
#}
#
#sub user_toolbar_exists {
#    my ($toolbar_name) = @_;
#    return exists $user_toolbars{$toolbar_name};
#}


# opts_ref nepouzite
sub create_new_user_toolbar {
    my ($grp, $toolbar_name, $opts_ref) = @_;
    # no user toolbars exist yet
    if (!keys %user_toolbars) {
    $grp->{UserToolbarSep}->pack(-after => $grp->{Toolbar},-fill=> 'x');
    $grp->{UserToolbars}->pack(-after => $grp->{UserToolbarSep},-fill=> 'x');
  }
  my $new_user_toolbar;
  if (exists $user_toolbars{$toolbar_name}) {
    croak "User Toolbar named $toolbar_name already exists!";
  } else {
    $user_toolbars{$toolbar_name} 
        = TrEd::Toolbar::User->new($grp, $toolbar_name);
  }
  _updateToolbarMenu($grp);
  return $user_toolbars{$toolbar_name};
  
}

sub get_user_toolbar {
    my ($toolbar_name) = @_;
    if (exists $user_toolbars{$toolbar_name}) {
        return $user_toolbars{$toolbar_name};
    }
    return;  
}

sub _updateToolbarMenu {
  my ($grp)=@_;
  my $menu = $grp->{toggleUserToolbarButton}->menu();
  $menu->delete(0,'end');
  $_->destroy for $menu->children;
  my $enabled=0;
  for my $name (sort keys %user_toolbars) {
    $enabled=1;
    $user_toolbars{$name}->add_to_menu($menu);
  }
  $grp->{toggleUserToolbarButton}->configure(-state => $enabled ? 'normal' : 'disabled');
}

sub destroy_user_toolbar {
    my($grp_or_win, $name) = @_;
    my $grp=main::cast_to_grp($grp_or_win);
  #delete $grp->{UserToolbarState}{$name};
  my $tb = delete $user_toolbars{$name};
  
  print "remove toolbar $name => $tb\n" if $TrEd::Config::tredDebug;
  return if ! defined $tb;
  $tb = $tb->getUserToolbar();
  
  if (keys %user_toolbars) {
    $tb->packForget();
  } else {
    $tb->packForget();
    $grp->{UserToolbars}->packForget;
    $grp->{UserToolbarSep}->packForget;
  }
  _updateToolbarMenu($grp);
  return $tb;
}

sub reset_user_toolbars {
    my($grp) = @_;
    for my $name (keys %user_toolbars) {
    my $tb = destroy_user_toolbar($grp,$name);
    if ($tb) {
      $tb->packForget;
      $tb->destroy;
    }
  }
  %user_toolbars=();
  return;
}


1;