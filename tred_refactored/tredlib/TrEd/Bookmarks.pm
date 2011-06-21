package TrEd::Bookmarks;

use TrEd::ManageFilelists;

use strict;
use warnings;

my $last_action_bookmark = q{};

sub get_last_action {
  return $last_action_bookmark;
}

sub set_last_action {
  my ($new_action_bookmark) = @_;
  $last_action_bookmark = $new_action_bookmark;
}


# tags: filelist, params, bookmarks
sub createBookmarksFilelist {
  # create Bookmarks filelist
  if (!bookmarkFilelist()) {
    if ($main::tredDebug) {
      print 'Bookmarks: ' . $ENV{HOME} . '/.tred_bookmarks' . "\n";
    }
    my $bookmarks = new Filelist('Bookmarks',$ENV{HOME} . '/.tred_bookmarks');
    TrEd::ManageFilelists::add_new_filelist(undef, $bookmarks);
  }
}

sub bookmarkFilelist {
  return TrEd::ManageFilelists::findFilelist('Bookmarks')
}

#TODO: toto je asi skor pre node ako pre bookmarks?
sub bookmarkThis {
  my ($grp)=@_;
  my $f=undef;
  my $win=$grp->{focusedWindow};
  if (ref($win->{FSFile})) {
    $f=$win->{FSFile}->filename()."##".($win->{treeNo}+1);
    my $nodeno=main::getNodeNo($win, $win->{currentNode});
    if (defined($nodeno)) {
      $f.=".$nodeno";
    }
  }
  return $f;
}


# bookmarks
sub addBookmark {
  my ($grp,$to_filelist)=@_;
  my $bl=defined($to_filelist) ? TrEd::ManageFilelists::findFilelist($to_filelist) : bookmarkFilelist();
  return unless ref($bl);
  my $f=bookmarkThis($grp);
  if (defined($f)) {
    TrEd::ManageFilelists::insertToFilelist($grp,$bl,$bl->count,$f);
    updateBookmarks($grp);
  }
}

# bookmarks
sub lastActionBookmark {
  my ($grp, $bookmark)=@_;
  # f? what is f?
  my $f = defined($bookmark) ? $bookmark : bookmarkThis($grp);
  if (defined($f)) {
    print STDERR "Bookmarking last action at: $f\n" if $main::tredDebug;
    $last_action_bookmark = $f;
    # updateBookmarks($grp);
  }
}


sub updateBookmarks {
  my ($grp)=@_;
  return if $grp->{noUpdatePostponed};
  if ($grp->{BookmarksFileMenu}) {
    print STDERR "Updating bookmark menu\n"  if $main::tredDebug;
    my $menu= $grp->{BookmarksFileMenu};
    $menu->delete(0, 'end');
    
    foreach my $menu_bookmark ($menu->children()) {
      $menu_bookmark->destroy();
    }

    my $i=0;
    my $bl = bookmarkFilelist();
    return unless ref ($bl);
    
    foreach my $b ($bl->files()) {
      print STDERR "$b\n" if $main::tredDebug;
      $menu->command(-label => "$i.  ".$b,
				      -underline=> 0,
				      -command=> [ \&main::openStandaloneFile,$grp,$b ]);
      $i++;
    }
    main::update_title_and_buttons($grp); # e.g. after adding/removing a bookmark to/from a filelist
  }
}



1;
