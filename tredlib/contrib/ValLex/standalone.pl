#!/usr/bin/perl

use Tk;
use Tk::Wm;

package Tk::Wm;
# overwriting the original Tk::Wm::Post:
sub Post
{
 my ($w,$X,$Y)= @_;
 $X= int($X);
 $Y= int($Y);
 $w->positionfrom('user');
# $w->geometry("+$X+$Y");
 $w->MoveToplevelWindow($X,$Y);
 $w->deiconify;
## This causes the "slowness":
# $w->raise;
}

package main;

use strict;
use Tk::Adjuster;
use Data;
use Widgets;
use Editor;


my $data=TrEd::ValLex::Data->new("pokus.xml");
#print $data->doc()->toString;

my $top=Tk::MainWindow->new();
my $vallex= TrEd::ValLex::Editor->new($data, $data->doc(),$top,0,1);
$vallex->pack(qw/-expand yes -fill both -side left/);

#  my $button_bar = $top->Frame()->pack(qw/ -expand no -side left/);;
#  my $to_left = $button_bar->Button(-text => '<-')->pack(qw/-pady 5/);
#  my $to_right = $button_bar->Button(-text => '->')->pack(qw/-pady 5/);

#  my $adjuster = $top->Adjuster();
#  $adjuster->packAfter($vallex->frame(), -side => 'left');

#  my $vallex2= TrEd::ValLex::View->new($data, $data->doc(),$top,1);
#  $vallex2->pack(qw/-expand yes -fill both -side left/);

MainLoop;

1;
