package TrEd::Query::User;

use strict;
use warnings;

use Tk;

# was main::userQuery
sub new_query {
  my ($win, $message, %opts) = @_;
  my $d = $win->toplevel->Dialog(
				 %opts
				);
  $d->add('Label', -text => $message,
	  -wraplength => 300)->pack();
  $d->BindReturn($d,1);
  if (exists($opts{-buttons}) and 
      grep { $_ eq 'Cancel' } @{$opts{-buttons}}) {
    $d->BindEscape();

  }
  $d->BindButtons;
  return $d->Show;
}

1;