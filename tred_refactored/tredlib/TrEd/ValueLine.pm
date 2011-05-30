package TrEd::ValueLine;

# value line je tak trocha nesikovne nazvany ten riadok, kde sa zobrazuje veta hore nad zobrazenim stromov... 

use strict;
use warnings;

use TrEd::Convert qw{encode};
use TrEd::Basics qw{setCurrent};
use Readonly;

Readonly my $EMPTY_STR => q{};

#TODO: nejak to prerobit, aby sa to volalo na value line objekt...?


# value line, UI
# sub set_value_line
sub set_value {
  my ($grp,$v)=@_;
  my $vl=$grp->{valueLine};
  $vl->configure(qw(-state normal));
  $vl->delete('0.0','end');
  my $rtl = $grp->{focusedWindow}->treeView->rightToLeft($grp->{focusedWindow}->{FSFile});
  if ($TrEd::Config::valueLineWrap eq 'word' and ($rtl or !defined($rtl) and $TrEd::Config::valueLineReverseLines)) {
    Tk::catch {
      $vl->configure(qw(-wrap none));
    };
    $v=reverseWrapLines($grp->{valueLine},$TrEd::Config::vLineFont,$v,
			$grp->{valueLine}->width()-15);
  } else {
    Tk::catch {
      $vl->configure(-wrap => ($TrEd::Config::valueLineWrap || 'word'));
    };
  }
  my @oldtags=grep {/^[a-zA-Z:]+=(?:HASH|ARRAY)/} $vl->tagNames();
  if (@oldtags) {
    $vl->tagDelete(@oldtags);
  }
  if (ref($v)) {
    my %tags;
    @tags{ map { @$_[1..$#$_] } @$v }=();
    foreach my $tag (keys(%tags)) {
      if ($tag=~/^\s*-/) {
	eval {
	  $vl->tagConfigure(
			    $tag => (map { (/^\s*(-[[:alnum:]]+)\s*=>\s*(.*\S)\s*$/) }  split(/,/,$tag)));
	};
	print $@ if $@;
      }
    }
    $vl->Subwidget('scrolled')->insert('end',$EMPTY_STR,undef,
				       map { ($_->[0], [reverse @$_[1..$#$_]]) } @$v);
  } else {
    $vl->Subwidget('scrolled')->insert('0.0',$v);
  }
  $vl->tagAdd('all','0.0','end');
  $vl->tagConfigure('all',-justify => (defined($rtl) ? ($rtl ? 'right' : 'left') : $TrEd::Config::valueLineAlign));
  $vl->configure(qw(-state disabled));
  return $v;
}

# value line
sub update_current {
  my ($win,$node)=@_;
  return if $win->{noRedraw};
  my $grp=$win->{framegroup};
  my $vl=$grp->{valueLine};
  if ($win == $grp->{focusedWindow}) {
    eval {
      $vl->tagRemove('current','0.0','end');
      $vl->tagRemove('sel','0.0','end');
      my $tag = main::doEvalHook($win, "highlight_value_line_tag_hook", $node);
      if (not defined $tag) {
        $tag = defined $node ? $node : $EMPTY_STR;
      }
      my ($first,$last)=('0.0','0.0');
      while (($first,$last)=$vl->tagNextrange("$tag",$last)) {
 	$vl->tagAdd('current',
		    $first,$last);
# 		    $tag.".first",
# 		    $tag.".last",
#	   );
 	$vl->see('current.first');
      }
    };
  }
}

# value line, UI
sub click {
  my ($w,$grp,$modif,$but)=@_;
  my $Ev=$w->XEvent;
  my $win=$grp->{focusedWindow};
  my (@tags)=
    $w->tagNames($w->index($Ev->xy));
  my $ret;
  if ($but eq 'Double-1' and $modif eq '') {
    main::doEvalHook($win,"value_line_click_hook", $but, $modif, \@tags);
    $ret = main::doEvalHook($win,"value_line_doubleclick_hook", @tags);
    $ret ||= $EMPTY_STR; 
    if (ref($ret) and UNIVERSAL::DOES::does($ret,'Treex::PML::Node')) {
      TrEd::Basics::setCurrent($win,$ret);
      main::ensureCurrentIsDisplayed($win);
      main::centerTo($win,$ret);
      Tk->break();
      return;
    } elsif ($ret ne 'stop') {
      my %nodes = map { $_=>$_ } @{ $win->{Nodes} };
      for my $t (reverse @tags) {
#	print STDERR "tag: $t\n";
	if (exists $nodes{$t}) {
	#  print STDERR "found $t\n";
	  my $node = $nodes{$t};
	  TrEd::Basics::setCurrent($win,$node);
	  main::ensureCurrentIsDisplayed($win);
	  main::centerTo($win,$node);
	  Tk->break();
	  return;
	}
      }
      # fallback
      my $node=$win->{root};
      while ($node) {
	if (index(join($EMPTY_STR,@tags),${node})>=0) {
	  TrEd::Basics::setCurrent($win,$node);
	  main::ensureCurrentIsDisplayed($win);
	  main::centerTo($win,$node);
	  Tk->break();
	  return;
	}
	$node=$node->following();
      }
    }
  } else {
    main::doEvalHook($win,"value_line_click_hook", $but, $modif, \@tags);
  }
  Tk->break();
}

# sub get_value_line
sub get_value_line {
  my ($win,$fsfile,$no,$no_numbers,$tags,$type)=@_;
  my $vl;
  if ($fsfile) {
    $vl=main::doEvalHook($win,"get_value_line_hook",$fsfile,$no,$type);
    if (defined($vl)) {
      if (ref($vl)) {
	unless ($tags) {
	  # important: encode inside - required by arabic, otherwise the text gets remixed
	  $vl = join $EMPTY_STR,map { TrEd::Convert::encode($_->[0]) } @$vl;
	} else {
	  $vl=[ map { $_->[0]=TrEd::Convert::encode($_->[0]); $_ } grep { $_->[0] ne $EMPTY_STR } @$vl ];
	}
      } else {
	$vl=TrEd::Convert::encode($vl);
      }
    } else {
      $vl=$win->treeView->value_line($fsfile,$no,$no_numbers,$tags,$win);
    }
  } else {
    $vl = $EMPTY_STR;
  }
  return $vl;
}

# value line
# sub update_value_line
sub update {
  my ($grp)=@_;
  my $win=$grp->{focusedWindow}; # only focused window uses the value line
  return if $win->{noRedraw};
  main::update_tree_pos($grp);
  my $vl = set_value($grp,get_value_line($win,$win->{FSFile},
					    $win->{treeNo},1,1,'value_line'));
  update_current($win,$win->{currentNode});
  return $vl;
}


1;
