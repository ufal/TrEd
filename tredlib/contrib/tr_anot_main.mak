## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-08-01 11:34:07 pajas>

#
# This file defines default macros for TR annotators.
# Only TredMacro context is present here.
#


sub file_opened_hook {

  # if this file has no balloon pattern, I understand it as a reason to override
  # its display settings!

  unless ($grp->{FSFile}->hint()) {
    default_tr_attrs();
  }

  foreach ("New Node","Remove Active Node","Insert New Tree",
	   "Insert New Tree After", "Remove Whole Current Tree") {
    $grp->{framegroup}->{NodeMenu}->entryconfigure($_,-state => 'disabled');
    $grp->{framegroup}->->{ContextsMenu}->configure(-state=>'disabled');
  }
  $FileNotSaved=0;
}

## add few custom bindings to predefined subroutines

# bind Save to F2 menu Save File
# bind SaveAndPrevFile to F11 menu Save and Go to Next File
# bind SaveAndNextFile to F12 menu Save and Go to Next File
# bind Find to F3 menu Find
# bind FindNext to F4 menu Find Next
# bind FindPrev to Ctrl+F4 menu Find Prev

# bind CutToClipboard to Ctrl+Insert menu Cut Subtree

sub CutToClipboard {
  return unless ($this and Parent($this));
  $nodeClipboard=$this;
  $this=RBrother($this) ? RBrother($this) : Parent($this);
  CutNode($nodeClipboard);
}

# bind PasteFromClipboard to Shift+Insert menu Paste Subtree
sub PasteFromClipboard {
  return unless ($this and $nodeClipboard);
  PasteNode($nodeClipboard,$this);
  $this=$nodeClipboard;
  $nodeClipboard=undef;
}


#bind GotoTreeAsk to key Alt+G menu Go to...
sub GotoTreeAsk {
  my $to=main::QueryString($grp->{framegroup},"Give a Tree Number","Number");

  $FileNotSaved=0;
  if ($to=~/#/) {
    for (my $i=$grp->{treeNo}+1; $i<=$grp->{FSFile}->lastTreeNo; $i++) {
      GotoTree($i+1), return if ($grp->{FSFile}->treeList->[$i]->{form} =~ $to);
    }
    for (my $i=0; $i<$grp->{treeNo}; $i++) {
      GotoTree($i+1), return if ($grp->{FSFile}->treeList->[$i]->{form} =~ $to);
    }
  } else {
    GotoTree($to) if defined $to;
  }
}

#bind LastTree to key Shift+greater menu Go to last tree
#bind LastTree to key Ctrl+Next
sub LastTree {
  GotoTree($grp->{FSFile}->lastTreeNo+1);
}

#bind FirstTree to key Shift+less menu Go to first tree
#bind FirstTree to key Ctrl+Prior
sub FirstTree {
  GotoTree(1);
}

#include tr_common.mak
