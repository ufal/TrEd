package TrEd::Basics;

use strict;
use warnings;

#This is a wrapper for pmltq extension, 
# when the extension will be updated 
# (i.e. TrEd::Basics::error_message() will be changed to TrEd::Error::Message::error_message()) 
# this wrapper (and whole file) can be safely removed
#see also TrEd::Error::Message
sub error_message {
    require TrEd::Error::Message;
    TrEd::Error::Message::error_message(@_);
}

1;

