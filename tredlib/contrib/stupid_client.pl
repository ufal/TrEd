#!/usr/bin/perl
# -*- cperl -*-

use Tk;

$remote_addr='localhost';
$remote_port='2345';

sub respond {
  print "Got: $_" if (defined($_=<INPUT>));
}

$top=MainWindow->new;

open INPUT,"$^X stupid_echoing_client.pl $remote_addr $remote_port |" || die "cannot init echoing client\n";

$top->fileevent(INPUT,"readable",\&respond);

MainLoop;


close (INPUT)	    || die "close: $!";



