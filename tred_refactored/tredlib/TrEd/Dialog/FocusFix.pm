package TrEd::Dialog::FocusFix;

use strict;
use warnings;

use Tk::DialogBox;

# This patches $dialog->Show which implicitly focuses the default button;
# here focus stays where it is.
# Usage: my $dlg=DialogBox(); ...; ShowDialog($dlg);
# dialog
sub show_dialog {
    my ( $cw, $focus, $oldFocus ) = @_;
    if ( !$oldFocus ) {
        $oldFocus = $cw->focusCurrent();
    }
    my $oldGrab    = $cw->grabCurrent();
    my $grabStatus = q{};
    if ($oldGrab) {
        my $grabStatus = $oldGrab->grabStatus();
    }

    $cw->Popup();

    Tk::catch {
        $cw->grab();
    };
    if ($focus) {
        $focus->focusForce();
    }
    Tk::DialogBox::Wait($cw);
    eval { $oldFocus->focusForce(); };

    $cw->withdraw;
    $cw->grabRelease;
    if ($oldGrab) {
        if ( $grabStatus eq 'global' ) {
            $oldGrab->grabGlobal();
        }
        else {
            $oldGrab->grab();
        }
    }

    return $cw->{selected_button};
}

# was main::RepeatedShowDialog
sub repeated_show_dialog {
    my ( $cw, $focus, $oldFocus ) = @_;
    $oldFocus = $cw->focusCurrent unless $oldFocus;
    my $oldGrab = $cw->grabCurrent;
    my $grabStatus = $oldGrab->grabStatus if ($oldGrab);

    # instead of Popup
    $cw->deiconify;
    $cw->waitVisibility;

    Tk::catch {
        $cw->grab;
    };
    $focus->focusForce if ($focus);
    Tk::DialogBox::Wait($cw);
    eval { $oldFocus->focusForce; };
    $cw->withdraw;
    $cw->grabRelease;
    if ($oldGrab) {
        if ( $grabStatus eq 'global' ) {
            $oldGrab->grabGlobal;
        }
        else {
            $oldGrab->grab;
        }
    }
    return $cw->{selected_button};
}

1;
