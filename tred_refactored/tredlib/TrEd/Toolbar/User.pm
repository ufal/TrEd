package TrEd::Toolbar::User;

use strict;
use warnings;

use TrEd::Config qw{$tredDebug};

use Carp;

#my $toolbar_state = 0;


sub new {
    my ( $class, $grp, $name ) = @_;
    my $value_line;

    if ( !ref $grp ) {
        croak("User toolbar constructor needs reference TrEd hash");
    }

    my $toolbar = $grp->{UserToolbars}->Frame->pack(-fill => 'x');
    my $toolbar_state = 1;

    my $obj = { 
        toolbar_state   => $toolbar_state,
        toolbar         => $toolbar,
        name            => $name,
    };
    return bless $obj, $class;
}


# user toolbar, UI
#sub _updateToolbarMenu {
#  my ($grp)=@_;
#  my $menu = $grp->{toggleUserToolbarButton}->menu();
#  $menu->delete(0,'end');
#  $_->destroy for $menu->children;
#  my $enabled=0;
#  for my $name (sort keys %{$grp->{UserToolbarHash}}) {
#    $enabled=1;
#    $menu->add('checkbutton',
#	       -label => $name.' toolbar',
#	       -variable => \$grp->{UserToolbarState}{$name},
#	       -command => [\&_toggleUserToolbar,$grp,$name],
#	      );
#  }
#  $grp->{toggleUserToolbarButton}->configure(-state => $enabled ? 'normal' : 'disabled');
#}

sub add_to_menu {
    my ($self, $menu) = @_;
    
    $menu->add('checkbutton',
	       -label => $self->{name}.' toolbar',
	       -variable => \$self->{toolbar_state},
	       -command => [\&toggleUserToolbar, $self],
	      );
}

# user toolbar, UI
sub toggleUserToolbar {
  my ($self)=@_;
  if ( $self->{toolbar_state} ) {
    $self->showUserToolbar();
  } else {
    $self->hideUserToolbar();
  }
}

# user toolbar, UI
sub hideUserToolbar {
  my ($self)=@_;
  my $tb = $self->{toolbar};  
  #getUserToolbar($grp,$name);
  if ($tb) {
    my $height = $tb->height();
    my %info = $tb->packInfo;
    my $master = $info{-in};
    $master->packPropagate(1);
    $tb->packForget();
    $master->update();
    $master->GeometryRequest($master->width,($master->reqheight-$height));
    $master->update();
    $self->{toolbar_state} = 0;
    #$grp->{UserToolbarState}{$name}=0;
    return $tb;
  }
  return 0;
}

# user toolbar, UI
sub showUserToolbar {
  my ($self)=@_;
  my $tb = $self->{toolbar};  
  #getUserToolbar($grp,$name);
  if ($tb) {
    $tb->pack(-fill=>'x');
    $self->{toolbar_state}=1;
    return $tb;
  }
  return 0;
}

# user toolbar, UI
sub userToolbarVisible {
  my ($self)=@_;
  my $tb =  $self->{toolbar};
  if ($tb) {
    return $self->{toolbar_state};
  }
  return;
}

#TODO: nazov zmenit
# user toolbar, UI
sub getUserToolbar {
  my ($self)=@_;
  return $self->{toolbar};
}

# user toolbar, UI
#sub removeUserToolbar {
#  my ($grp_or_win,$name)=@_;
#  my $grp=cast_to_grp($grp_or_win);
#  my $tb = delete $grp->{UserToolbarHash}{$name};
#  delete $grp->{UserToolbarState}{$name};
#  print "remove toolbar $name => $tb\n" if $TrEd::Config::tredDebug;
#  return unless $tb;
#  if (keys %{$grp->{UserToolbarHash}}) {
#    $tb->packForget;
#  } else {
#    $tb->packForget;
#    $grp->{UserToolbars}->packForget;
#    $grp->{UserToolbarSep}->packForget;
#  }
#  _updateToolbarMenu($grp);
#  return $tb;
#}


1;