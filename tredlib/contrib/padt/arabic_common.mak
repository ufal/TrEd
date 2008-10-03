# -*- cperl -*-

#include "arabic_keymod.mak"

use lib CallerDir();
use lib CallerDir("PADT");

sub start_hook {

  UnbindBuiltin('Shift+Home');
  UnbindBuiltin('Shift+End');

  return;
}

sub init_hook {

    $support_unicode = $Tk::VERSION gt 804.00;

    $ArabicRendering = $^O eq 'MSWin32' || $support_unicode;

    $TrEd::Convert::inputenc = 'iso10646-1';
    $TrEd::Convert::outputenc = $ArabicRendering ? 'iso10646-1' : 'iso-8859-6';

    initialize_direction('right-to-left', 'right');

    print STDERR "File encoding ", $TrEd::Convert::inputenc, "\n";
    print STDERR "View encoding ", $TrEd::Convert::outputenc, "\n";
}

sub initialize_direction {

    print STDERR "Forcing '$_[0]' direction and '$_[1]' text alignment\n";

    $TrEd::Convert::lefttoright = $_[0] ne 'right-to-left' || $ArabicRendering ? 1 : 0;

    $TrEd::Config::valueLineReverseLines = $_[0] eq 'right-to-left' ? 1 : 0;
    $TrEd::Config::valueLineAlign = $_[1];

    $main::treeViewOpts->{reverseNodeOrder} = $_[0] eq 'right-to-left' ? 1 : 0;

    #   foreach (@{$grp->{framegroup}->{treeWindows}}) {
    #       $_->treeView->apply_options($main::treeViewOpts);
    #   }

    $TrEd::TreeView::DefaultNodeStyle{NodeLabel} = [ -valign => 'top', -halign => $_[1] ];
    $TrEd::TreeView::DefaultNodeStyle{Node} = [ -textalign => $_[1] ];

    main::read_config();

    eval { main::reconfigure($grp->{framegroup}) };
}

# if text is not rendered fine, use this function to provide
# a reversed nodelist for both the value_line and the tree
# (since reverseNodeOrder is intended only for the tree)

sub get_nodelist_hook {

    return undef if $ArabicRendering;

    my ($nodes, $current) = $_[0]->nodes(@_[1 .. 3]);

    return [[reverse @{$nodes}], $current];
}
