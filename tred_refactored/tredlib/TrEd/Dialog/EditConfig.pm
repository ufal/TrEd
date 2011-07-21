package TrEd::Dialog::EditConfig;

use strict;
use warnings;

use Tk;
use TrEd::Config;

require TrEd::RuntimeConfig;

sub show_dialog {
  my ($grp)=@_;
  return unless $grp;
  if ($grp->{configDialog}) {
    $grp->{configDialog}->deiconify();
    $grp->{configDialog}->focus();
    $grp->{configDialog}->raise();
    return;
  }
  $grp->{configDialog}
    = $grp->{top}->Toplevel(-title => "Edit Config File ($TrEd::Config::config_file)" , 
                            -width => "10c");
  my $d=$grp->{configDialog};
  $d->withdraw;
  $d->BindReturn($d,1);
  my @text_opt = eval { require Tk::CodeText; 
			require Tk::CodeText::TrEdConfig; 
		      } ? (qw(CodeText -syntax TrEdConfig -commentchar ;))
			: qw(Text);
  my $t= $d->Scrolled(@text_opt, 
		      qw/-relief sunken -borderwidth 2
			-height 20 -scrollbars oe/);
  my $edit = $t->Subwidget('scrolled');
  main::_deleteMenu($edit->menu,'File');
  if ($text_opt[0] eq 'CodeText') {
    my $syntax = $edit->menu->entrycget('View','-menu')->entrycget('Syntax','-menu');
    my $last = $syntax->index('last');
    if ($last ne 'none') {
      $syntax->delete($_) for grep { defined and !/^(None|Perl|TrEdConfig)$/ }
	map { eval { local $SIG{__DIE__}; $syntax->entrycget($_,'-label')} } 0..$last
    }
    $edit->menu->entrycget('View','-menu')->delete('Rules Editor');
  }
  #TODO: extract callbacks
  $t->bind('<Alt-f>'  => sub {
	     my ($w)=@_;
	     my $pop=$w->FindPopUp();
	     my ($entry) = grep { $_->isa('Tk::Entry') } $pop->children();
	     $pop->bind('<Tab>',[sub { shift->focusNext; }]);
	     $pop->bind('<Escape>',[sub { shift; shift->destroy; },$pop]);
	     if (ref($entry)) {
	       $entry->focus();
	     }
	   });
  $t->bind('<Alt-r>'  => sub {
	     my ($w)=@_;
	     my $pop=$w->FindAndReplacePopUp();
	     my ($entry) = grep { $_->isa('Tk::Entry') } $pop->children();
	     $pop->bind('<Tab>',[sub { shift->focusNext(); }]);
	     $pop->bind('<Escape>',[sub { shift; shift->destroy; },$pop]);
	     if (ref($entry)) {
	       $entry->focus();
	     }
	   });
  $t->pack(qw/-side top -expand yes -fill both/);

  main::disable_scrollbar_focus($t);
  $t->BindMouseWheelVert();
  my $bottom=$d->Frame()->pack(qw/-side bottom -fill x/);
  $t->TextSearchLine(-parent => $d,
		     -label=>'S~earch',
		     -prev_img => main::icon($grp,'16x16/up'),
		     -next_img => main::icon($grp,'16x16/down'),
		    )->pack(qw(-fill x -side top));
  #TODO: extract callbacks
  $bottom->
    Button(-text=> "  Save and Apply  ",
	   -underline => 2,
	   -command=> [sub {
			  my ($grp,$d,$t)=@_;
			  TrEd::RuntimeConfig::save_config($d,[$t->get("0.0","end")], $main::opt_q);
			  TrEd::Config::apply_config(split(/\n/,$t->get("0.0","end")));
			  main::reconfigure($grp);
			  main::get_nodes_all($grp);
			  main::redraw_all($grp);
			},$grp,$d,$t])
      ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $bottom->Button(-text=> "  Apply  ",
		  -underline => 2,
		  -command=> [sub {
				 my ($grp,$w)=@_;
				 TrEd::Config::apply_config(split(/\n/,$w->get("0.0","end")));
				 main::reconfigure($grp);
				 main::get_nodes_all($grp);
				 main::redraw_all($grp);
			       },$grp,$t])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $bottom->Button(-text=> "  Help  ", 
		  -underline => 2,
		  -command=> [sub { 
				main::help_topic(shift,'configuration');
				Tk->break;
			      },$d])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $bottom->Button(-text=> "  Close  ", 
		  -underline => 2,
		  -command=> [sub { shift->destroy(); },$d])
    ->pack(-side=> 'left', -expand=> 1,  -padx=> 1, -pady=> 1);
  $d->BindButtons();
  $d->bind('<Destroy>'=> [sub { shift; shift->{configDialog}=undef; },$grp ]);
  $d->bind($d,'<Escape>'=> [sub { shift; shift->destroy(); },$d]);
  my $config = TrEd::RuntimeConfig::get_config_from_file() || [];
  TrEd::RuntimeConfig::update_runtime_config($grp,$config);
  $t->insert('0.0' , join(q{}, @{$config}) . "\n");
  $t->mark(qw/set insert 0.0/);
  $t->focus();
  $d->Popup();
}

1;