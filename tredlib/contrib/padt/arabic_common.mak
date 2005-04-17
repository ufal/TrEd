# -*- cperl -*-
use lib "$main::libDir/contrib/padt";
use lib "$main::libDir/contrib/padt/PADT";

sub init_hook {

    $support_unicode=($Tk::VERSION gt 804.00);

    # does the OS or TrEd+Tk support propper arabic rendering
    $ArabicRendering=($^O eq 'MSWin32' or $support_unicode);

    # if not, at least reverse all non-asci strings
    unless ($ArabicRendering) {
      print STDERR "Arabic: Forcing right-to-left\n";
      $TrEd::Convert::lefttoright=0;
    }

    $TrEd::Config::valueLineReverseLines=1;
    $TrEd::Config::valueLineAlign='right';

    # display nodes in the reversed order
    print STDERR "Arabic: Forcing reverseNodeOrder\n";
    $main::treeViewOpts->{reverseNodeOrder}=1;
    foreach (@{$grp->{framegroup}->{treeWindows}}) {
      $_->treeView->apply_options($main::treeViewOpts);
    }

    # setup file encodings
    if ($^O eq 'MSWin32') {
      $TrEd::Convert::outputenc='windows-1256';
      print STDERR $TrEd::Convert::inputenc,"\n";
    } elsif ($support_unicode) {
      $TrEd::Convert::outputenc='iso10646-1';
      print STDERR $TrEd::Convert::outputenc,"\n";
    } else {
      $TrEd::Convert::outputenc='iso-8859-6';
      print STDERR $TrEd::Convert::outputenc,"\n";
    }
    $TrEd::Convert::inputenc='windows-1256';

    # setup CSTS header
    Csts2fs::setupPADTAR();

    # align node labels to right for more natural look
    $TrEd::TreeView::DefaultNodeStyle{NodeLabel}=
      [-valign => 'top', -halign => 'right'];
    $TrEd::TreeView::DefaultNodeStyle{Node}=
      [-textalign => 'right'];

    # reload config
    main::read_config();
    eval {
      main::reconfigure($grp->{framegroup});
    };
}

# if arabic text is not rendered ok, use this function to provide a
# reversed nodelist for both value_line and the tree (since
# reverseNodeOrder is intenden only for the tree)

sub get_nodelist_hook {
  my ($fsfile,$tree_no,$prevcurrent,$show_hidden)=@_;
  return undef if $ArabicRendering;

  my ($nodes,$current)=$fsfile->nodes($tree_no,$prevcurrent,$show_hidden);
  return [[reverse @$nodes],$current];
}
