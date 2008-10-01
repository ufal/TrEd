package Report;

use strict;

use Carp;

use IO::Handle;

$Carp::CarpLevel = 1;

# typical set of errorlevels: DEBUG, INFO, WARN, ERROR, FATAL


# how many characters of a string-eval are to be shown in the output
$Carp::MaxEvalLen = 100;

my $unfinished_line;

sub _ntred_message ($) {
    my $message = shift;
    {
        no strict;
        no warnings;
        if ($main::is_in_ntred) {
            #      print "QQQQQQQQQQ IS_IN_NTRED: $main::is_in_ntred\n";
            main::_msg $message;
        }
    }
}

sub fatal($) {
    my $message = shift;
    if ($unfinished_line) {
        print STDERR "\n";  $unfinished_line = 0;
    }
    my $line = "TMT-FATAL:\t$message\n\nPERL ERROR MESSAGE: $!\n $@\nPERL STACK:";
    _ntred_message($line);
    confess $line;
}

sub warn($) {
    my $message = shift;
    #  Carp::cluck "TMT-WARN:\t$message";
    my $line = "";
    if ($unfinished_line) {
        $line = "\n";  $unfinished_line = 0;
    }
    $line .= "TMT-WARN:\t$message\n";
    _ntred_message($line);
    print STDERR $line;
}

sub debug($) {
    my $message = shift;
    my $line = "";
    if ($unfinished_line) {
        $line = "\n";  $unfinished_line = 0;
    }
    $line .= "TMT-DEBUG:\t$message";
    _ntred_message($line);
    Carp::cluck $line;
}

sub data($) {
    my $message = shift;
    my $line = "";
    if ($unfinished_line) {
        $line = "\n";  $unfinished_line = 0;
    }
    $line .= "TMT-DATA:\t$message\n";
    _ntred_message($line);
    print STDERR $line;
}

sub info($) {
    my $message = shift;
    my $line = "";
    if ($unfinished_line) {
        $line = "\n";  $unfinished_line = 0;
    }
    $line .= "TMT-INFO:\t$message\n";
    _ntred_message($line);
    print STDERR $line;
}

sub info_unfinished($) {
    my $message = shift;
    my $line = "";
    if ($unfinished_line) {
        $line = "\n";  $unfinished_line = 0;
    }
    $line .= "TMT-INFO:\t$message";
    _ntred_message($line);
    print STDERR $line;
    STDERR->flush;
    $unfinished_line = 1;
}

sub info_finish($) {
    my $message = shift;
    my $line = "";
    if (not $unfinished_line) {
        $line = "\nTMT-INFO:\t";
    }
    $unfinished_line = 0;
    $line .= "$message\n";
    _ntred_message($line);
    print STDERR $line;
}

sub progress() { # progress se pres ntred neposila, protoze by se stejne neflushoval
    if (not $unfinished_line) {
        print STDERR "TMT-PROGRESS:\t";
    }
    print STDERR "*";
    STDERR->flush;
    $unfinished_line = 1;
}


1;
