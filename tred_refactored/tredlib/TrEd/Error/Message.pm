package TrEd::Error::Message;

use strict;
use warnings;


our $VERSION = "0.1";
our $on_error = undef;

#######################################################################################
# Usage         : _message_box($top, $title, $msg, $nobug)
# Purpose       : Displays an error message in GUI
# Returns       : Nothing
# Parameters    : hash_ref $top   -- reference to toplevel GUI window
#                 scalar $title   -- title of the message window
#                 scalar $msg     -- message to be displayed in the message window
#                 scalar $nobug   -- severity of message -- 'warn' means warning, everything else means error
# Throws        : no exception
# Comments      : requires Tk::ErrorReport
# See Also      : Tk::ErrorReport()
sub _message_box {
    my ( $top, $title, $msg, $nobug ) = @_;
    require Tk::ErrorReport;
    $nobug ||= '';
    $top->ErrorReport(
        -title   => $title,
        -msgtype => ( $nobug eq 'warn' ? "WARNING" : "ERROR" ),
        -message => (
            $nobug eq 'warn'
            ? "Operation produced warnings - full message follows.\n"
            : $nobug ? "Operation failed - full error message follows.\n"
            : "An error occured during a protected transaction.\n"
                . "If you believe that it was caused by a bug in TrEd, you may wish to\n"
                . "copy the error message displayed below and report it to the author."
        ),
        -body => $msg,
    );
    return;
}

#######################################################################################
# Usage         : error_message($win_ref, $msg, $nobug)
# Purpose       : Displays an error message in GUI if $top is set, otherwise the error 
#                 message is written to console. Calls on_error() callback, if it is set
# Returns       : Nothing
# Parameters    : TrEd::Window ref $win_ref -- ref to TrEd::Window object
#                 scalar $msg       -- message to be displayed in the message window
#                 scalar $nobug     -- severity of message -- 'warn' means warning, everything else means error
# Throws        : no exception
# Comments      : requires Tk::ErrorReport
# See Also      : _message_box(), Tk::ErrorReport()
sub error_message {
    my ( $win_ref, $msg, $nobug ) = @_;
    if (defined $on_error) {
        &$on_error(@_);
    }
    else {
        my $top;
        if ( ref($win_ref) =~ /^Tk::/ ) {
            $top = $win_ref->toplevel();
        }
        elsif ( ref($win_ref) eq 'Mainwin_refdow' ) {
            $top = $win_ref;
        }
        elsif ( exists( $win_ref->{framegroup} )
            and ref( $win_ref->{framegroup} )
            and exists( $win_ref->{framegroup}{top} )
            and ref( $win_ref->{framegroup}{top} ) )
        {
            $top = $win_ref->{framegroup}->{top}->toplevel();
        }

        if ($top) {

# report the error from the highest displayed toplevel window in stacking order
            warn $msg;
            my ($highest) = reverse $top->stackorder();
            $top = $top->Widget($highest);
            _message_box( $top, 'Error', $msg, $nobug );
        }
        else {
            print STDERR "$msg\n";
        }
    }
}



1;

__END__

=head1 NAME


TrEd::Error::Message - Basic error reporting subroutines


=head1 VERSION

This documentation refers to 
TrEd::Error::Message version 0.1.


=head1 SYNOPSIS

  use TrEd::Error::Message;
  use TrEd::Window; # for GUI error messages
  
  my $win_ref = TrEd::Window->new(newTreeView($grp), framegroup => $grp);
  
  my $msg = "Message for the user\n";
  my $nobug = "nobug";
  
  # console output
  TrEd::Error::Message::error_message({}, $msg, $nobug);
  
  # GUI output
  TrEd::Error::Message::error_message($win_ref, $msg, $nobug);
  

=head1 DESCRIPTION

This module contains basic functions for reporting errors to user using Tk or console approach, 
whichever is more appropriate. 


=head1 SUBROUTINES/METHODS

=over 4 

=item * C<TrEd::Error::Message::_message_box($top, $title, $msg, $nobug)>

=over 6

=item Purpose

Displays an error message in GUI


=item Parameters

  C<$top> -- hash_ref $top   -- reference to toplevel GUI window
  C<$title> -- scalar $title   -- title of the message window
  C<$msg> -- scalar $msg     -- message to be displayed in the message window
  C<$nobug> -- scalar $nobug   -- severity of message -- 'warn' means warning, everything else means error

=item Description

requires Tk::ErrorReport


=item See Also

L<Tk::ErrorReport>,

=item Returns

Nothing


=back


=item * C<TrEd::Error::Message::error_message($win_ref, $msg, $nobug)>

=over 6

=item Purpose

Displays an error message in GUI if $top is set, otherwise the error 
message is written to console. Calls on_error() callback, if it is set


=item Parameters

  C<$win_ref> -- TrEd::Window ref $win_ref -- ref to TrEd::Window object
  C<$msg> -- scalar $msg       -- message to be displayed in the message window
  C<$nobug> -- scalar $nobug     -- severity of message -- 'warn' means warning, everything else means error

=item Description

requires Tk::ErrorReport


=item See Also

L<_message_box>,
L<Tk::ErrorReport>,

=item Returns

Nothing


=back



=back


=head1 DIAGNOSTICS

No diagnostic messages. 

=head1 CONFIGURATION AND ENVIRONMENT

This module does not require special configuration or enviroment settings.

=head1 DEPENDENCIES

CPAN modules:
Tk,

TrEd modules:
no

Standard Perl modules:
no

=head1 INCOMPATIBILITIES

No known incompatibilities.


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to 
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

Copyright (c) 
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests). 
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut
