package TrEd::MinorModes;

use strict;
use warnings;

use Carp;

# minor mode
# sub declareMinorMode
sub declare_minor_mode {
    my ( $grp_or_win, $name, $opts ) = @_;

    #  use Data::Dumper;
    #  print Dumper(\%main::);
    #  print Dumper(\%main::grp_win);
    #  print Dumper(\&main::grp_win);
    #  main::__debug('Hello');
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    if ( exists $grp->{minorModes}{$name} ) {
        carp("WARNING: re-declaration of an existing minor context $name");
    }
    $grp->{minorModes}{$name} = $opts;
    for my $type (qw(pre post)) {
        my $hooks = $opts->{ $type . '_hooks' };
        if ( ref $hooks eq 'HASH' ) {
            foreach my $hook ( keys %$hooks ) {
                $grp->{ 'minor' . ucfirst($type) . 'Hooks' }{$hook}{$name}
                    = $hooks->{$hook};
            }
        }
    }
    for my $tp ( [qw(bindings minorKeyBindings)],
        [qw(priority_bindings minorKeyPriorityBindings)] )
    {
        my ( $type, $store ) = @{$tp};
        if ( ref $opts->{$type} eq 'ARRAY' ) {
            for my $binding ( @{ $opts->{$type} } ) {
                my $key   = $binding->{key};
                my $macro = $binding->{command};
                if ( defined $key and defined $macro ) {
                    $grp->{$store}{$name}{$key} = $macro;
                }
            }
        }
        elsif ( ref( $opts->{$type} ) eq 'HASH' ) {
            $grp->{$store}{$name} = $opts->{$type};
        }
    }
    update_minor_modes($grp);
}

# minor mode
# sub enableMinorMode {
sub enable_minor_mode {
    my ( $grp_or_win, $name ) = @_;
    my ( $grp,        $win )  = main::grp_win($grp_or_win);
    if ( ref( $win->{minorModes} ) ) {
        if ( !TrEd::MinMax::first { $_ eq $name } @{ $win->{minorModes} } ) {
            push @{ $win->{minorModes} }, $name;
        }
    }
    else {
        $win->{minorModes} = [$name];
    }
    update_minor_modes($win);
}

# minor mode
# sub disableMinorMode {
sub disable_minor_mode {
    my ( $grp_or_win, $name ) = @_;
    my ( $grp,        $win )  = main::grp_win($grp_or_win);
    if ( ref $win->{minorModes} ) {
        @{ $win->{minorModes} }
            = grep { $_ ne $name } @{ $win->{minorModes} };
    }
    update_minor_modes($win);
}

# minor mode
# sub toggleMinorMode {
sub toggle_minor_mode {
    my ( $grp_or_win, $name ) = @_;
    my ( $grp,        $win )  = main::grp_win($grp_or_win);
    if ( ref $win->{minorModes} ) {
        if ( TrEd::MinMax::first { $_ eq $name } @{ $win->{minorModes} } ) {
            disable_minor_mode( $grp_or_win, $name );
        }
        else {
            enable_minor_mode( $grp_or_win, $name );
        }
    }
    else {
        enable_minor_mode( $grp_or_win, $name );
    }
    $win->get_nodes();
    $win->redraw();
    $win->ensure_current_is_displayed();
    main::centerTo( $win, $win->{currentNode} );
}

# minor mode
#TODO: decrypt this...
sub _minor_ctxt_abbrev {
    my ( $grp, $name ) = @_;

    #  $name=~s/[aeiouy]//gi;
    #  return $name;
    return $grp->{minorModes}{$name}{abbrev}
        || join '', $name =~ m/(?:^|(?<=_|\s|-))(.)/g;
}

# minor mode
sub configure_minor_mode {
    my ( $l, $grp, $name ) = @_;
    my $cmd = $grp->{minorModes}{$name}{configure};
    if ( defined($cmd) && $cmd ) {
        main::doEvalMacro( $grp->{focusedWindow}, $cmd );
    }
}

# minor mode
sub update_minor_modes {
    my ($grp_or_win) = @_;
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    if ( $grp_or_win == $grp and $grp->{minorModesMenu} ) {
        update_minor_mode_menu( $grp, $grp->{minorModesMenu}->cget('-menu'),
            0 );
        update_minor_mode_menu( $grp, $grp->{MinorModesMainMenu}, 1 );
    }
    if (   defined $grp->{focusedWindow}
        && defined $win
        && $grp->{focusedWindow} == $win )
    {
        my %activate = map { $_ => 1 } @{ $win->{minorModes} };
        for my $name ( keys %{ $grp->{minorModesLabels} } ) {
            if ( not( delete $activate{$name} ) ) {
                my $l = delete $grp->{minorModesLabels}{$name};
                $l->packForget();
                $l->destroy();
            }
        }
        for my $name ( grep $activate{$_}, @{ $win->{minorModes} } ) {
            my $l = $grp->{minorModesLabels}{$name}
                = $grp->{minorModesLabelFrame}->Label(
                -text             => _minor_ctxt_abbrev( $grp, $name ) . ' ',
                -activeforeground => 'darkblue',
                -highlightcolor   => 'blue',
                )->pack( -side => 'right' );
            $l->bind( '<Double-1>', [ \&configure_minor_mode, $grp, $name ] );
            if ( $grp->{minorModes}{$name}{configure} ) {
                $grp->{Balloon}->attach( $l,
                    -balloonmsg => "Double-click to configure '$name'" );

                $l->bind( '<Enter>', [qw(configure -state active)] );
                $l->bind( '<Leave>', [qw(configure -state normal)] );
            }
        }
        my $enabled = $grp->{enabledMinorModesMenu} ||= {};
        if ( ref $win->{minorModes} ) {
            $enabled->{$_} = 0 for grep !$activate{$_}, keys %$enabled;
            $enabled->{$_} = 1 for @{ $win->{minorModes} };
        }
    }
}

# minor mode, UI
#TODO: mozno do samostatnej pkg, kedze sa tyka menu...
sub update_minor_mode_menu {
    my ( $grp, $menu, $checkbuttons ) = @_;
    return unless $menu;
    $menu->delete( 0, 'end' );
    $_->destroy for $menu->children;
    my $i = 0;
    foreach my $name ( sort keys %{ $grp->{minorModes} || {} } ) {
        my $nice_name = $name;
        $nice_name =~ tr/_/ /;
        if ($checkbuttons) {
            $menu->checkbutton(
                -label => "$nice_name ("
                    . _minor_ctxt_abbrev( $grp, $name ) . ")",
                -variable => \$grp->{enabledMinorModesMenu}{$name},
                -command  => [ \&toggle_minor_mode, $grp, $name ]
            );
        }
        else {
            $menu->command(
                -label => _minor_ctxt_abbrev( $grp, $name ) . ":  $nice_name",
                -command => [ \&toggle_minor_mode, $grp, $name ]
            );
        }
    }
}

1;
