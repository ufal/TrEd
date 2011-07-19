package TrEd::Dialog::Text;

use strict;
use warnings;

use Tk;

# a simple dialog with one big text entry
# UI, Dialog
sub create_dialog {
  my ($grp_or_win,$dialog_opts,$label1_opts,$label2_opts,$text_opts,$msg,$bind)=@_;
  my ($grp,$win) = main::grp_win($grp_or_win);
  my $d= $grp->{top}->DialogBox( %$dialog_opts   );
  $d->Label( %$label1_opts )
    ->pack(-pady => 5,-side => 'top', -fill => 'x')  if defined $label1_opts;
  $d->Label( %$label2_opts )->pack(-pady => 10,-side => 'top', -fill => 'x')
    if defined $label2_opts;
  my $tags = delete $text_opts->{-tags};
  my $t=$d->Scrolled(
    (delete $text_opts->{-readonly} ? 'ROText' : 'Text'),
    qw/-relief sunken -borderwidth 2 -scrollbars oe/,%$text_opts);
  main::_deleteMenu($t->Subwidget('scrolled')->menu,'File');
  $t->pack(qw/-side top -expand yes -fill both/);
  $t->BindMouseWheelVert();
  if ($bind) {
    my %b = ( dialog => $d, text => $t );
    foreach my $what (keys %b) {
      if (ref($bind->{$what})) {
	foreach (@{$bind->{$what}}) {
	  $b{$what}->bind(@$_);
	}
      }
    }
  }
  $t->insert('0.0',ref($msg) ? @$msg : $msg);
  $t->markUnset('insert');
  $t->markSet('insert','0.0');
  if (ref($tags)) {
    foreach my $tag (keys %$tags) {
      $t->tagConfigure($tag,@{$tags->{$tag}})
    }
  }
  $t->focus();
  $d->Show();
}


1;
