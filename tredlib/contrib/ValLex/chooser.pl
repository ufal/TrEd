#!/usr/bin/perl -I.. -I../..
use Tk;
use Tk::Wm;
use Benchmark;
use Tk::BindMouseWheel;

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
use LibXMLData;
use Widgets;
use Editor;
use Chooser;
use TrEd::CPConvert;


sub questionQuery {
  my ($top,$title, $message,@buttons) = @_;

  my $d = $top->DialogBox(-title => $title,
				       -buttons => [@buttons]
				      );
  $d->add('Label', -text => $message, -wraplength => 200)->pack;
  $d->bind('<Return>', sub { my $w=shift; my $f=$w->focusCurrent;
			     $f->Invoke if ($f and $f->isa('Tk::Button')) } );
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  return $d->Show;
}

my $support_unicode = ($Tk::VERSION ge 804.00);
my $conv= TrEd::CPConvert->new("utf-8",
			       $support_unicode ? "utf-8" :
			       (($^O eq "MSWin32") ?
				"windows-1250" :
				"iso-8859-2"));

my $data=TrEd::ValLex::LibXMLData->new(-f "vallex.xml.gz" ? "vallex.xml.gz" : "vallex.xml",$conv,1);

my $font = "-adobe-helvetica-medium-r-*-*-12-*-*-*-*-*-iso8859-2";
my $fc=[-font => $font];
my $fe_conf={ elements => $fc,
	      example => $fc,
	      note => $fc,
	      problem => $fc
	    };
my $vallex_conf = {
		   framelist => $fc,
		   framenote => $fc,
		   frameproblem => $fc,
		   wordlist => { wordlist => $fc, search => $fc},
		   wordnote => $fc,
		   wordproblem => $fc,
		   infoline => { label => $fc }
		  };

my $top=Tk::MainWindow->new();
my $find=$ARGV[0];
$top->title("Choose frame: $find");
my $word=$data->findWord($find);
my $new_word=0;

unless ($word) {
  if (questionQuery($top,"Word does not exist",
		    "Do you want to add this word to the lexicon?",
		    "Yes", "No") eq "Yes") {
    $word=$data->addWord($find,"V");
    $new_word=1;
  } else {
    print "No such word in the lexicon\n";
    exit;
  }
}

sub close_and_return {
  my ($chooser,@frames)=@_;
  my $value=join " ", map { $_->getAttribute('frame_ID') } @frames;
  print "value: $value\n";
  $top->destroy();
}

#my $top=Tk::MainWindow->new();
#TrEd::ValLex::Chooser::show_dialog($find, $top,$data,$word);

#if ($word) {
my $chooser= TrEd::ValLex::Chooser->new($data, [$find,"V"], $top,
					1,
					$fc,
					$vallex_conf,
					$fc,
					$fc,
					$fe_conf,
					\&close_and_return,0);

if ($new_word) {
  $chooser->widget()->afterIdle([\&TrEd::ValLex::Chooser::edit_button_pressed,$chooser]);
} else {
  $chooser->subwidget("framelists")->[0]->fetch_data($word);
}
undef $word;

$chooser->pack(qw/-expand yes -fill both -side left/);
$chooser->subwidget("framelists")->[0]->select_frames(split '\|',$ARGV[1]);

#}

#  my $button_bar = $top->Frame()->pack(qw/ -expand no -side left/);;
#  my $to_left = $button_bar->Button(-text => '<-')->pack(qw/-pady 5/);
#  my $to_right = $button_bar->Button(-text => '->')->pack(qw/-pady 5/);

#  my $adjuster = $top->Adjuster();
#  $adjuster->packAfter($vallex->frame(), -side => 'left');

#  my $vallex2= TrEd::ValLex::View->new($data, $data->doc(),$top,1);
#  $vallex2->pack(qw/-expand yes -fill both -side left/);

#$top->Popup();

MainLoop;


1;
