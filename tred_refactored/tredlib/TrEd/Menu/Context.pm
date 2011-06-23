package TrEd::Menu::Context;


use strict;
use warnings;


use Tk;

sub new {
    my ($class, $menubar_frame, $grp) = @_;
    if (!ref $grp) {
        croak("Context menu constructor needs reference to menubar frame and TrEd hash");
    }

    my $context_menu = $menubar_frame->Optionmenu(
                            -options      => [],
                            -textvariable => \$grp->{selectedContext},
                            -font         => 'C_small',
                            -command      => [\&_switch_context_callback, $grp], #option value is appended to args
                            -relief       => 'groove', #$menubarRelief,
                            -borderwidth  => 2)->pack(qw/-side right -padx 5/);

  $context_menu->menu()->bind("<KeyPress>", [\&main::NavigateMenuByFirstKey,Tk::Ev('K')]);
  
  my $obj = {
        context_menu => $context_menu,
    };
  return bless $obj, $class;
}

sub _switch_context_callback { 
    my ($grp,$context) = @_;
    main::switchContext($grp->{focusedWindow}, $context);
}

# this method has to be named options, because it is only a wrapper that was created 
# because extensions set options for this menu
sub options {
    my ($self, @opts) = @_;
    return $self->{context_menu}->options(@opts);
}

#sub configure {
#    my ($self, @opts) = @_;
#    return $self->{context_menu}->configure(@opts);
#}

sub get_menu {
    my ($self) = @_;
    return $self->{context_menu};
}

sub set_options {
    my ($self, @opts) = @_;
    return $self->{context_menu}->configure(-options => @opts);
}

1;
