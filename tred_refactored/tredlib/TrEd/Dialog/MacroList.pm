# asi to bude chciet urobit include aj dajakeho Tk
package TrEd::Dialog::MacroList;

use strict;
use warnings;

use TrEd::Macros;
use TrEd::Basics qw{$EMPTY_STR};
use TrEd::Error::Message;

use TrEd::List::Macros;
use TrEd::HTML::Simple;

use Tk;



# macro, menu, UI
sub create_dialog {
  my ($grp)=@_;
  my $context=$grp->{focusedWindow}->{macroContext};
  if ($grp->{Macrolist}) {
    $grp->{Macrolist}->deiconify;
    $grp->{Macrolist}->focus;
    $grp->{Macrolist}->raise;
    return;
  }
  unless (scalar(TrEd::Macros::get_contexts())) {
    TrEd::Error::Message::error_message($grp->{focusedWindow},"No named macros in current context ($context)",1);
    return;
  }
  my $d= $grp->{top}->Toplevel(-title=> "List of available macros");
  $d->withdraw();
  $d->resizable(0,1);
  $d->minsize('200','200');
#c  -Background white
  my $topframe = $d->Frame;
  my $t = TrEd::List::Macros::create_list($grp,$topframe,\$context);
  $t->header(configure=>$_,-underline=>0) for 0..2;
  $t->configure(-height => 25);
  TrEd::List::Macros::create_items($grp,$t,$context,
		       $grp->{macroListAnonymous},
		       $grp->{macroListCalls},
		       $grp->{macroListOrder},
		       0
		      );
  $grp->{Macrolist}=$d;
  my $renew_callback = [sub { #shift;
		    my ($grp,$t,$ctxt)=@_;
		    TrEd::List::Macros::create_items($grp,$t,$$ctxt,
					 $grp->{macroListAnonymous},
					 $grp->{macroListCalls},
					 $grp->{macroListOrder},
					 0
					);
		  },$grp,$t,\$context];
  
  my $f=$topframe->Frame();
  $f->Label(-text => "Mode: ",
	    -underline => 1,
	   )->pack(qw/-side left/);
  my $om = 
    $f->Optionmenu(-options      => [get_contexts()],
		   -textvariable => \$context,
		   -command      => $renew_callback,
		   -relief       => 'groove', #$menubarRelief,
		   -borderwidth  => 2);
		   #TODO:
  $om->menu->bind("<KeyPress>", [\&main::NavigateMenuByFirstKey,Ev('K')]);
  $om->pack(qw/-side left -padx 5/);

  $d->bind("<Alt-o>"=>
	     [sub {
		my ($w,$but,$val)=@_;
		my $menu = $but->menu;
		my $idx = eval { $menu->index($$val) } || 0;
		$but->Post();
		$menu->activate($idx);
		Tk->break;
	      },$om,\$context]);
  $f->Button(-text=> 'Export as HTML',
	     -underline => 0,
	     -command=> [ sub {
			    my ($w,$grp,$t,$ctxt)=@_;
			    my $html = TrEd::HTML::Simple::open($t,$$ctxt.".html","Save list of $$ctxt macros",$ENV{HOME});
			    if ($html) {
			      print $html "<h2>TrEd Macros - $$ctxt</h2>\n";
			      print $html "<table>\n";
			      my $odd = 0;
			      foreach my $child ($t->info('children',$EMPTY_STR)) {
				print $html "  <tr ",($odd ? 'bgcolor="#ffffff"' : 'bgcolor="#eeeeee"'),
				  ">\n    <td>",$t->itemCget($child,0,'-text'),"</td>\n",
				  ($grp->{macroListCalls} ? "<td>".$t->itemCget($child,1,'-text')."</td>\n" : $EMPTY_STR),
				  "<td>", $t->itemCget($child,2,'-text'),"</td>\n",
				  "  </tr>\n";
				$odd = !$odd;
			      }
			      print $html "</table>\n";
			      TrEd::HTML::Simple::close($html);
			    }
			  },$d,$grp,$t,\$context ])->pack(-padx=>'0.5c',-pady=>'0.2c',-side=>'right');

  my $rf = $f->Frame()->pack(-side=> 'right',-padx=> 20);
  $rf->Radiobutton(-anchor  => 'nw',
		   -underline => 8,
		   -text    => 'Sort by keyboard shortcut',
		   -variable=> \$grp->{macroListOrder},
		   -relief  => 'flat',
		   -command => $renew_callback,
		   -value   => 'K'
		 )->pack(-side=> 'top', -fill => 'x');
  $rf->Radiobutton(-anchor  => 'nw',
		   -underline => 8,
		   -text    => 'Sort by name',
		   -variable=> \$grp->{macroListOrder},
		   -relief  => 'flat',
		   -command => $renew_callback,
		   -value   => 'M'
		 )->pack(-side=> 'top', -fill => 'x');
  $rf->Radiobutton(-anchor  => 'nw',
		   -underline => 8,
		   -text    => 'Sort by Perl name',
		   -variable=> \$grp->{macroListOrder},
		   -relief  => 'flat',
		   -command => $renew_callback,
		   -value   => 'P'
		 )->pack(-side=> 'top', -fill => 'x');

  my $chf = $f->Frame()->pack(-side=> 'right',-padx=> 20);
  $chf->Checkbutton(-anchor  => 'nw',
		   -underline => 0,
		   -text    => 'Include anonymous macros',
		   -variable=> \$grp->{macroListAnonymous},
		   -relief  => 'flat',
		   -command => $renew_callback,
		 )->pack(-side=> 'top', -fill => 'x');

  $chf->Checkbutton(-anchor  => 'nw',
		   -underline => 5,
		   -text    => 'See Perl names',
		   -variable=> \$grp->{macroListCalls},
		   -relief  => 'flat',
		   -command => $renew_callback,
		 )->pack(-side=> 'top', -fill => 'x');

  my $botframe=$d->Frame();
  $botframe->Button(-text=> 'Run and Close',
		    -underline => 0,
	     -command=> [ sub {
			     my ($w,$grp,$t,$ctxt)=@_;
			     my $macro=$t->info(data => $t->info('anchor'));
			     $w->destroy();
			     if (ref($macro) eq 'Tk::Callback') { # CODE ref gets mangled to Tk::Callback by Tk
			       $macro=$macro->[0];
			     }
			     #TODO: toto bez strcenia do ineho namespace-u asi nezavolame... jedine zeby main::?
			     main::doEvalMacro($grp->{focusedWindow},$macro);
			   },$d,$grp,$t,\$context ])->pack(-padx=>'0.5c',-pady=>'0.2c',-side=>'left');


  $botframe->Button(-text=> 'Close',
		    -underline => 0,
		     -command=> [ sub {
				     shift->destroy();
				   },$d ])->pack(-padx=>'0.5c',-pady=>'0.2c',-side=>'right');
  $d->bind($d,'<Destroy>'=> [sub { shift; shift->{Macrolist}=undef; },$grp ]);
  $d->bind($d,'<Escape>'=> [sub {  
				 if ($_[0]->isa('Tk::Menu')) {
				   $_[0]->Leave
				 } else {
				   $_[1]->toplevel->destroy(); 
				 }
			       },$d ]);
  $d->bind($om,'<Escape>'=> sub { shift->Leave; });


  $f->pack(qw/-side bottom -fill x/);
  $t->pack(qw/-side top -fill both -expand 1/);


  $botframe->pack(qw/-side bottom -fill both/);
  $topframe->pack(qw/-side top -fill both -ipady 3 -ipadx 3 -expand 1/);

  $d->BindButtons;
  $t->focus;
  $d->Popup;
}




1;