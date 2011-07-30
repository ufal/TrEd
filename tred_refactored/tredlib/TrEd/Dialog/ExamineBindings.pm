package TrEd::Dialog::ExamineBindings;

use strict;
use warnings;

use TrEd::Macros;
use TrEd::Utils qw{$EMPTY_STR};
use TrEd::Binding::Default qw{normalize_key};

sub examineEvent {
    my $w        = shift;
    my $bindings = shift;
    my $grp      = $_[0];
    my ( $macro, $key, $eA, $eK, $by_event_hook, $rotated )
        = main::resolveEvent( $w, @_ );
    $key ||= $EMPTY_STR;
    if ( $eA eq $eK ) {
        $key .= " [$eA]" if ( $eA ne $key );
    }
    else {
        my $rot = $rotated ? ' /rotated because of vertical mode/ ' : '';
        if ( $eA eq $key ) {
            $key .= " [$eK]$rot";
        }
        elsif ( $eK eq $key ) {
            $key .= " [$eA]$rot";
        }
        else {
            $key .= " [$eA = $eK]$rot";
        }
    }
    if ($by_event_hook) {
        if ( defined($macro) ) {
            $$bindings = "$key bound by event_hook to: "
                . TrEd::Macros::findMacroDescription( $grp, $macro );
        }
        else {
            $$bindings = "$key is blocked by event_hook\n";
        }
    }
    else {
        if ( defined($macro) ) {
            $$bindings = "$key is bound to: "
                . TrEd::Macros::findMacroDescription( $grp, $macro );
        }
        else {
            $$bindings = "$key is not bound\n";
        }
    }

    # turn printing on only in debug mode
    print $$bindings. "\n" if $TrEd::Config::tredDebug;
    Tk->break();
}

# sub examineBindingsDialog
sub create_dialog {
    my ($grp)      = @_;
    my $bindings   = 'None';
    my $dialog_box = $grp->{top}->DialogBox(
        -title   => "Examine key bindings",
        -buttons => ["Close"]
    );

    $dialog_box->BindEscape();
    $dialog_box->Label( qw/-wraplength 6i -justify left -text/,
        "Press any key to see it's binding in the current context." )
        ->pack(qw/-padx 0 -pady 10 -expand yes -fill both/);
    my $t = $dialog_box->Label( -textvariable => \$bindings )
        ->pack(qw/-padx 0 -pady 10 -expand yes -fill both/);

    $dialog_box->bind(
        '<KeyPress>' => [ \&examineEvent, \$bindings, $grp, $EMPTY_STR ] );

    foreach my $prefix ( 'Alt', 'Meta', 'Mod4' ) {
        $dialog_box->bind( "<$prefix-KeyPress>" =>
                [ \&examineEvent, \$bindings, $grp, uc($prefix) . '+' ] );
    }
    foreach (
        qw(Shift Control Meta Alt Mod4 Control-Shift Control-Alt
        Control-Meta Control-Mod4 Alt-Shift Alt-Mod4 Meta-Shift Mod4-Shift)
        )
    {
        foreach my $event (
            qw(KeyPress Right Left Up Down
            Return comma period Next Prior greater less)
            )
        {
            $dialog_box->bind(
                "<$_-$event>" => [
                    \&examineEvent, \$bindings, $grp,
                    TrEd::Binding::Default::normalize_key($_) . "+"
                ]
                )
                unless ( "$_-$event" eq "Alt-KeyPress"
                or "$_-$event" eq "Meta-KeyPress" );
        }
    }

    my $set_bindings_func
        = sub { $bindings = "builtin $_[2] - $_[1]"; Tk->break(); };
    my $default_binding = $grp->{default_binding};
    while ( my ( $key, $def )
        = each %{ $default_binding->get_default_bindings() } )
    {
        $dialog_box->bind( $key => [ $set_bindings_func, $def->[1], $key ] );
    }

    my $context           = $grp->{focusedWindow}->{macroContext};
    my $set_override_func = sub {
        $bindings = "builtin $_[2] overriden in $context - $_[1]";
        Tk->break();
    };
    while ( my ( $key, $def )
        = each %{ $default_binding->get_context_bindings($context) || {} } )
    {
        $dialog_box->bind( $key => [ $set_override_func, $def->[1], $key ] );
    }

    $dialog_box->Show();
    $dialog_box->destroy();
    undef $dialog_box;
}

1;
