#
# The help widget that provides both "balloon" and "status bar"
# types of help messages.

package Tk::HelpTiptool;

use vars qw($VERSION);
$VERSION = '0.1'; # $Id$

use Tk qw(Ev Exists);
use Carp;
require Tk::Toplevel;

Tk::Widget->Construct('HelpTiptool');
use base qw(Tk::Toplevel);
use Tk::widgets qw(ROText);

use UNIVERSAL;

use strict;

my @balloons;
my $button_up = 0;


sub Populate {
    my ($w, $args) = @_;
    my $message = delete $args->{-message};
    $w->SUPER::Populate($args);

    $w->overrideredirect(1);
    $w->withdraw;
    # Only the container frame's background should be black... makes it
    # look better.
    $w->configure(-background => 'black');
    my $m = $w->Frame;
    $m->configure(-bd => 0,-borderwidth => 0);
    my $b = $m->Frame;
    $b->pack(-fill => 'y', -side => 'right');
    $b->Button(-command => [$w,'ButtonDown'],
	       -relief => 'ridge',
	       -image => $w->Bitmap(-data => <<'EOF'))->pack(-side => 'top');
#define cross_width 5
#define cross_height 5
static unsigned char cross_bits[] = {
   0x11, 0x0a, 0x04, 0x0a, 0x11};
EOF

    my $ml = $m->Scrolled('ROText',
			  -bd => 0,
			  -setgrid => 1,
			  -takefocus => 0,
			  -highlightthickness => 0,
			  -borderwidth => 0,
			  -wrap => 'word',
			  -relief => 'flat',
			  -scrollbars => 'ow',
			  -padx => 0,
			  -pady => 0);
    $ml->insert('0.0',(ref($message) eq 'ARRAY' ? @$message : $message));
    $w->Advertise('text' => $ml);
    $ml->pack(-side => 'left',
	      -anchor => 'w',
	      -expand => 1,
	      -fill => 'both');
    $m->pack(-fill => 'both', -side => 'left');
    $ml->Subwidget('scrolled')->bind($ml->Subwidget('scrolled'),'<3>', [$w,'ButtonDown']);
    $ml->Subwidget('scrolled')->menu(undef);
    $ml->Subwidget('yscrollbar')->configure(-width=>7);

    # append to global list of balloons
    $w->{'popped'} = 0;
    $w->{'buttonDown'} = 0;
    $w->ConfigSpecs(-installcolormap => ['PASSIVE', 'installColormap', 'InstallColormap', 0],
		    -state => ['PASSIVE', 'state', 'State', 'both'],
		    -background => ['DESCENDANTS', 'background', 'Background', '#C0C080'],
		    -troughcolor => ['DESCENDANTS', 'troughcolor', 'Background', '#C0C080'],
		    -font => [$ml, 'font', 'Font', '-*-helvetica-medium-r-normal--*-120-*-*-*-*-*-*'],
		    -borderwidth => ['SELF', 'borderWidth', 'BorderWidth', 1]
		   );
}


sub insert {
  my $w = shift;
  $w->Subwidget('text')->insert(@_);
}

sub ButtonDown {
    my ($ewin) = @_;
    $ewin->Deactivate;
}

sub ButtonUp {
    $button_up = 1;
}


sub Deactivate {
    my ($w) = @_;
    print "Deactivating: $w->{'popped'}\n";
    if ($w->{'popped'}) {
      $w->withdraw;
      $w->{'popped'} = 0;
    }
}

sub Toggle {
    my $w = shift;
    if ($w->{'popped'}) {
      $w->Deactivate;
    } else {
      $w->Popup(@_);
    }
}

sub Popup {
    my ($w,$client) = @_;
    if ($w->cget(-installcolormap)) {
	$w->colormapwindows($w->winfo('toplevel'))
    }
    $w->idletasks;
    return unless Exists($w);
    return unless Exists($client);

    my ($x, $y);
    $x = int($client->rootx + $client->width/2);
    $y = int($client->rooty + int ($client->height/1.3));
    $w->idletasks;
    my($width, $height) = ($w->reqwidth, $w->reqheight);
    my $xx = ($x + $width > $w->screenwidth
	      ? $w->screenwidth - $width
	      : $x);
    my $yy = ($y + $height > $w->screenheight
	      ? $w->screenheight - $height
	      : $y);

    $w->geometry("+$xx+$yy");
    #$w->MoveToplevelWindow($x,$y);
    $w->deiconify();
    $w->{'popped'} = 1;
    $w->raise;
    #$w->update;  # This can cause confusion by processing more Motion events before this one has finished.
}

1;

