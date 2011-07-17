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

# context list, menu, UI
# context menu
#######################################################################################
# Usage         : update_context_list($grp)
# Purpose       : Update list of contexts in context menu, set $grp->{selectedContext}
#                 according to allowed contexts and switch context
# Returns       : Undef/empty list
# Parameters    : hash_ref $grp -- reference to hash containing TrEd options
# Throws        : No exception
# Comments      : 
# See Also      : 
sub update_context_list {
    my ($self, $grp) = @_;
    if ( defined $self ) {
        my $selected_context = $grp->{selectedContext};
        my %new = map { $_ => 1 } 
                  main::get_allowed_contexts( $grp->{focusedWindow} );
        my $tredmacro_ok = delete $new{TredMacro};
        my @allowed_contexts = [ ( $tredmacro_ok ? 'TredMacro' : () ), 
                            sort keys %new 
                          ];
        $self->set_options(@allowed_contexts);
        
        # if the selected context has changed, select TredMacro, 
        # if it's allowed; otherwise try to use macro context 
        # specified as a command line parameter
        #TODO: kind of feature envy, isn't it?
        if ( $selected_context ne $grp->{selectedContext} ) {
            if ($tredmacro_ok) {
                $grp->{selectedContext} = 'TredMacro';
            }
            elsif ( defined $main::init_macro_context
                    && exists($new{$main::init_macro_context}) ) 
            {
                $grp->{selectedContext} = $main::init_macro_context;
            }
            main::switchContext( $grp->{focusedWindow}, $grp->{selectedContext},
                1 );
        }
    }
    return;
}

1;
