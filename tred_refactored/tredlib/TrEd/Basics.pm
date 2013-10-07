package TrEd::Basics;

use strict;
use warnings;

use Scalar::Util qw(blessed);

#This is a wrapper for pmltq extension, 
# when the extension will be updated 
# (i.e. TrEd::Basics::error_message() will be changed to TrEd::Error::Message::error_message()) 
# this wrapper (and whole file) can be safely removed
#see also TrEd::Error::Message
sub error_message {
    require TrEd::Error::Message;
    TrEd::Error::Message::error_message(@_);
}

# Window, UI?
sub cast_to_win {
    my ($gw) = @_;
    return
        ( blessed($gw) and $gw->isa('TrEd::Window') ) ? $gw
        : (
        ref $gw ? $gw->{focusedWindow}
        : undef
        );
}

# Window
sub cast_to_grp {
    my ($gw) = @_;
    return ( blessed($gw) and $gw->isa('TrEd::Window') )
        ? $gw->{framegroup}
        : $gw;
}

# grp?
sub grp_win {
    my ($gw) = @_;
    return ( cast_to_grp($gw), cast_to_win($gw) );
}


1;

