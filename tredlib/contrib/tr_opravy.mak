## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2002-11-13 17:52:32 pajas>


package TR_Correction;
@ISA=qw(Tectogrammatic);
import Tectogrammatic;

# permitting all attributes modification
sub enable_attr_hook {
  return;
}

#bind add_ord_patterns to key Shift+F8 menu Show ord, dord, sentord, and del, AID/TID
sub add_ord_patterns {
  return unless $grp->{FSFile};
  my @pat=GetDisplayAttrs();
  my $hint=GetBalloonPattern();

  SetDisplayAttrs(@pat,'<? #corr ?>${ord}/${sentord}/${dord}/${del}',
		  '<? #corr ?>${AID}','<? #corr ?>${TID}');
}

#bind try_fix_AID to key Alt+i menu addremove TID, generate AID from ord
sub try_fix_AID {
  return unless $grp->{FSFile};
  unless ($this->{ord}=~/\./) {
    if ($this->{TID} ne "") {
      $this->{AID}=$this->{TID};
      $this->{AID}=~s/a\d+$/w$this->{ord}/;
      $this->{TID}="";
    } elsif ($this->{AIDREFS} ne "") {
      ($this->{AID})=grep { /w$this->{ord}$/ } split /\|/,$this->{AIDREFS};
      if ($this->{AID} eq '') {
	($this->{AID})=split /\|/,$this->{AIDREFS};
	$this->{AID}=~s/w\d+$/w$this->{ord}/;
      }
    }
  }
}


sub remove_ord_patterns {
  SetDisplayAttrs(grep { !/ \#corr / } GetDisplayAttrs());
}
