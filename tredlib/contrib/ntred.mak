# -*- cperl -*-

# Macros for comunnicating with a BTrEd Server

sub Position { print ThisAddressNTRED(@_),"\n"; }

my $perl_syntax_highlighting =
  [
   ['Comment_Normal', -foreground => 'red'],
   ['Comment_Pod', -foreground => 'red'],
   ['Directive', -foreground => 'darkblue'],
   ['Label', -foreground => 'cyan'],
   ['Quote', -foreground => 'brown'],
   ['String', -foreground => 'brown'],
   ['Variable_Scalar', -foreground => 'DarkOrange'],
   ['Variable_Array', -foreground => 'DarkOrange2'],
   ['Variable_Hash', -foreground => 'DarkOrange3'],
   ['Subroutine', -foreground => 'blue'],
   ['Character', -foreground => 'magenta'],
   ['Keyword', -foreground => 'magenta4'],
   ['Builtin_Operator', -foreground => 'darkgreen'],
   ['Operator', -foreground => 'green3'],
   ['Number', -foreground => 'darkblue'],
  ];

sub ntred_query {
  my ($query,$T,$N,$args)=@_;
  $query=~s/\\/\\/g;
  $query=~s/'/'"'"'/g;

  $cmd="ntred ".
    ($T ? '-T ' : '').
    ($N ? '-N ' : '').
      "-e '$query' $args";
  print STDERR "$cmd\n";
  open my $fh, "$cmd |";
  binmode $fh,':utf8' if $TrEd::Convert::support_unicode;
  local $/;
  my $result = <$fh>;
  return $result;
}

sub ntred_query_box {
  if ($NTredQueryDialog) {
    $NTredQueryDialog->deiconify;
    $NTredQueryDialog->focus;
    $NTredQueryDialog->raise;
    return;
  }

  my $d=$NTredQueryDialog=ToplevelFrame()
    ->Toplevel(-title => "Query remote BTrEd servers",
	       -width=> "20c");
  $NTredQueryDialogAllTrees=1;
  $NTredQueryDialogAllNodes=1;
  $d->withdraw;
  $d->bind('<Destroy>'=> [sub { shift; $NTredQueryDialog=undef; },$grp ]);
  $d->bind('<Escape>', [sub { shift;shift->destroy; },$d] );
  $d->protocol('WM_DELETE_WINDOW' => [sub { shift->destroy; },$d]);
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  require Tk::Adjuster;
  my $bottom=$d->Frame()->pack(qw/-side top -fill x -expand no/);
  my $topframe=$d->Frame()->pack(qw/-side top -fill x/);
  my $Nb=$topframe->Checkbutton(-text    => 'All trees',
			 -variable=> \$NTredQueryDialogAllTrees,
			 -relief  => 'flat')->pack(qw(-fill y -anchor nw -side left));
  my $Nb=$topframe->Checkbutton(-text    => 'All nodes',
			 -variable=> \$NTredQueryDialogAllNodes,
			 -relief  => 'flat')->pack(qw(-fill y -anchor nw -side left));
  my @normalTextWidget = qw(Text);
  my @textWidget;
  if (eval { require Tk::CodeText }) {
    @textWidget = (qw(CodeText -syntax Perl),
		   -rules => $perl_syntax_highlighting);
  } else {
    @textWidget = @normalTextWidget;
  }
  my $t= $d->Scrolled(@textWidget,qw/-relief sunken -borderwidth 2 -height 15 -scrollbars oe/,
		      -font => StandardTredFont()
		     );
  $t->insert('end',"# insert your query here\n\n");
  my $tm=$d->Adjuster(-widget => $m ,-side => 'bottom');
  my $m= $d->Scrolled(@textWidget,qw/-relief sunken -borderwidth 2 -height 10 -scrollbars oe/,
		      -font => StandardTredFont()
		     );
  $m->insert('end','# insert macros here'."\n\n");
  my $mr=$d->Adjuster(-widget=>$m, -side => 'top');
  my $r= $d->Scrolled(@normalTextWidget,qw/-relief sunken -borderwidth 2 -height 20 -scrollbars oe/,
		      -font => StandardTredFont()
		     );
  for ($t, $m, $r) {
    $_->bind('<Alt-f>'  => sub {
	       my ($w)=@_;
	       my $pop=$w->FindPopUp();
	       my ($entry) = grep { $_->isa('Tk::Entry') } $pop->children();
	       $pop->bind('all','<Tab>',[sub { shift->focusNext; }]);
	       $pop->bind('all','<Escape>',[sub { shift; shift->destroy; },$pop]);
	       if (ref($entry)) {
		 $entry->focus();
	       }
	     });
    $_->bind('<Alt-r>'  => sub {
	       my ($w)=@_;
	       my $pop=$w->FindAndReplacePopUp();
	       my ($entry) = grep { $_->isa('Tk::Entry') } $pop->children();
	       $pop->bind('all','<Tab>',[sub { shift->focusNext; }]);
	       $pop->bind('all','<Escape>',[sub { shift; shift->destroy; },$pop]);
	       if (ref($entry)) {
		 $entry->focus();
	       }
	     });
    $_->pack(qw/-side top -expand yes -fill both/);
    main::disable_scrollbar_focus($_);
    $_->BindMouseWheelVert();
  }
  $tm->packAfter($t);
  $mr->packAfter($m);
  $bottom->Button(-text=> "  Close  ", -command=> [sub { shift->withdraw; },$d])
    ->pack(qw(-side left -expand yes -padx 1 -pady 1));
  $bottom->Button(-text=> "  Query  ",
		  -command=> [\&ntred_query_box_do_query,$grp,$t,$m,$r])
    ->pack(qw(-side left -expand yes -padx 1 -pady 1));
  $bottom->Button(-text=> "  Make Filelist  ",
		  -command=> [\&ntred_query_box_make_filelist,$grp,$r])
    ->pack(qw(-side left -expand yes -padx 1 -pady 1));

  $t->focus();
  $d->Popup;
  $FileChanged=0;
}

sub ntred_query_box_do_query {
  my ($grp,$t,$m,$r)=@_;
  $r->delete("0.0","end");
  my $macro = $m->get("0.0","end");
  require Fcntl;
  require POSIX;
  do {
    local *FH;
    do { $tmp_name = tmpFileName(); } until
      sysopen(FH,$tmp_name, Fcntl::O_RDWR|Fcntl::O_CREAT|Fcntl::O_EXCL);
    print FH $macro;
    close FH;
  };
  my $result=ntred_query($t->get("0.0","end"),
			 $NTredQueryDialogAllTrees,
			 $NTredQueryDialogAllNodes,
			 "-m $tmp_name "
			);
  $r->insert('end',$result);
  my $title=$r->toplevel->title();
  $title=~s/ \(\d+ lines of output\)//;
  $r->toplevel->title($title." (".scalar(map $_,$result=~/\n/g)." lines of output)");
  unlink($tmp_name) or die "Couldn't unlink $tmp_name : $!";
}

sub ntred_query_box_make_filelist {
  my ($grp,$r)=@_;
  my $name='ntred_client';
  my $fl=main::findFilelist($name);
  print STDERR $fl,"\n";
  $fl=main::addFilelist(Filelist->new($name)) unless $fl;
  $fl->clear();
  $fl->add(0,split /\n/,$r->get("0.0","end"));
  &main::updatePostponed($grp->{framegroup});
  &main::selectFilelist($grp->{framegroup},$name);
}
