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
	       -command => [\&toggle_user_toolbar, $self],
	      );
}

# was main::toggleUserToolbar
sub toggle_user_toolbar {
  my ($self)=@_;
  if ( $self->{toolbar_state} ) {
    $self->show();
  } else {
    $self->hide();
  }
}

# user toolbar, UI
# was main::hideUserToolbar
sub hide {
  my ($self)=@_;
  my $tb = $self->{toolbar};  
  #get_user_toolbar($grp,$name);
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
sub show {
  my ($self)=@_;
  my $tb = $self->{toolbar};  
  #get_user_toolbar($grp,$name);
  if ($tb) {
    $tb->pack(-fill=>'x');
    $self->{toolbar_state}=1;
    return $tb;
  }
  return 0;
}

# user toolbar, UI
sub visible {
  my ($self)=@_;
  my $tb =  $self->{toolbar};
  if ($tb) {
    return $self->{toolbar_state};
  }
  return;
}


# was main::getUserToolbar
sub get_user_toolbar {
  my ($self)=@_;
  return $self->{toolbar};
}



1;