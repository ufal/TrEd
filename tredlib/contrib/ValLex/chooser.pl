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
use Chooser;


my $data=TrEd::ValLex::Data->new("pokus.xml");
#print $data->doc()->toString;

my $top=Tk::MainWindow->new();
my $find=$ARGV[0];
my $word=$data->findWord($find);

sub close_and_return {
  my ($chooser,$frame)=@_;
  my $value=$frame->getAttribute('frame_ID');
  print "value: $value\n";
  $top->destroy();
}

TrEd::ValLex::Chooser::show_dialog($find, $top,$data,$word);

#if ($word) {
#  my $chooser= TrEd::ValLex::Chooser->new($data, $word ,$top,\&close_and_return,0);
#  $chooser->pack(qw/-expand yes -fill both -side left/);
#}

#  my $button_bar = $top->Frame()->pack(qw/ -expand no -side left/);;
#  my $to_left = $button_bar->Button(-text => '<-')->pack(qw/-pady 5/);
#  my $to_right = $button_bar->Button(-text => '->')->pack(qw/-pady 5/);

#  my $adjuster = $top->Adjuster();
#  $adjuster->packAfter($vallex->frame(), -side => 'left');

#  my $vallex2= TrEd::ValLex::View->new($data, $data->doc(),$top,1);
#  $vallex2->pack(qw/-expand yes -fill both -side left/);

MainLoop;

1;
