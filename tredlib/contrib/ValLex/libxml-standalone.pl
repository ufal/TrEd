#!/usr/bin/perl -I.. -I../..
use FindBin;
my $binDir=$FindBin::RealBin;
my $libDir;
if (exists $ENV{TREDHOME}) {
  $libDir=$ENV{TREDHOME};
} elsif (-d "$binDir/../..") {
  $libDir="$binDir/../..";
} elsif (-d "$binDir/../lib/tredlib") {
  $libDir="$binDir/../lib/tredlib";
} elsif (-d "$binDir/../lib/tred") {
  $libDir="$binDir/../lib/tred";
}

push @INC, $libDir, "$libDir/contrib";# "$libDir/contrib/ValLex";

use Tk;
use Tk::Wm;

require locale;
use POSIX qw(locale_h);
setlocale(LC_COLLATE,"cs_CZ");
setlocale(LC_NUMERIC,"us_EN");
setlocale(LANG,"czech");

package Tk::Wm;
# overwriting the original Tk::Wm::Post:
sub Post
{
 my ($w,$X,$Y)= @_;
 $X= int($X);
 $Y= int($Y);
 $w->positionfrom('user');
 $w->MoveToplevelWindow($X,$Y);
 $w->deiconify;
}

package main;

require strict;
require Tk::Adjuster;
require ValLex::Data;
require ValLex::LibXMLData;
require ValLex::Widgets;
require ValLex::Editor;
require TrEd::CPConvert;

my $double = 0;

my $conv= TrEd::CPConvert->new("utf-8",
			       ($^O eq "MSWin32") ?
			       "windows-1250" :
			       "iso-8859-2");
my $data_file=$ARGV[0];
die "Usage: $0 <file>\n" if $ARGV[0] eq "";
my $data=TrEd::ValLex::LibXMLData->new($data_file,$conv,1);

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
my $top_frame = $top->Frame()->pack(qw/-expand yes -fill both -side top/);


my $vallex= TrEd::ValLex::Editor->new($data, undef,$top_frame,0,
				      $fc, # wordlist items
				      $fc, # framelist items
				      $fe_conf);
$vallex->subwidget_configure($vallex_conf);
$vallex->pack(qw/-expand yes -fill both -side left/);
$top->title("Frame editor: ".$data->getUserName($data->user()));

my $button_bar = $top->Frame()->pack(qw/ -expand no -side left/);;
#my $to_left = $button_bar->Button(-text => '<-')->pack(qw/-pady 5/);
#my $to_right = $button_bar->Button(-text => '->')->pack(qw/-pady 5/);

if ($double) {
  my $adjuster = $top_frame->Adjuster();
  $adjuster->packAfter($vallex->frame(), -side => 'left');
  my $vallex2= TrEd::ValLex::Editor->new($data, undef,$top_frame,1);
  $vallex2->pack(qw/-expand yes -fill both -side left/);
}

my $bottom_frame = $top->Frame()->pack(qw/-expand yes -fill both -side bottom/);

my $save_button=
  $bottom_frame->Button(-text => "Reload",
			-command =>
			[sub {
			   my ($d,$f)=@_;
			   $d->Busy(-recurse=> 1);
			   my $field=$f->subwidget("wordlist")->focused_word();
			   $f->data()->reload();
			   $f->fetch_data();
			   if ($field) {
			     my
			       $word=$f->data()->findWordAndPOS(@{$field});
			     $f->wordlist_item_changed($f->subwidget("wordlist")->focus($word));

			   }
			   $d->Unbusy(-recurse=> 1);
			 },$top,$vallex]
		       )->pack(qw/-side right -pady 10 -padx 10/);


my $save_button=$bottom_frame->Button(-text => "Save",
			     -command => sub {
			       $vallex->save_data($top);
			     })->pack(qw/-side right -pady 10 -padx 10/);


$top->protocol('WM_DELETE_WINDOW'=> 
	     [sub { my ($self,$top)=@_;
		    $self->ask_save_data($top)
		      if ($self->data()->changed());
		    $top->destroy();
		    undef $top;
		  },$vallex,$top]);


MainLoop;

1;
