## -*- cperl -*-
## author: Petr Pajas
## Time-stamp: <2001-08-13 10:50:56 pajas>

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
  }
  my $o=$grp->{framegroup}->{ContextsMenu};
  $o->options(['Tectogrammatic','TR_Diff']);
  SwitchContext('Tectogrammatic');
  $FileNotSaved=0;
}

sub file_resumed_hook {
  SwitchContext('Tectogrammatic');
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

sub editQuery {
  ## draws a dialog box with one Text widget and Ok/Cancel buttons
  ## expects dialog title and default text
  ## returns text of the Text widget
  my $d;
  my $ed;

  $d=ToplevelFrame()->DialogBox(-title => shift,
			   -buttons => ["OK","Cancel"]);
  main::addBindTags($d,'dialog');
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  $d->bind('all','<Shift-Tab>',[sub { shift->focusPrev; }]);
  my $var=shift;
  my $hintText=shift;
  if ($hintText) {
    my $t=$d->add(qw/Label -wraplength 6i -justify left -text/,$hintText);
    $t->pack(qw/-padx 0 -pady 10 -expand yes -fill both/);
  }
  $ed=$d->Scrolled(qw/Text -height 8 -relief sunken -scrollbars sw -borderwidth 2/,-font => $main::font);
  $ed->insert('0.0',$var);
  $ed->pack(qw/-padx 0 -pady 10 -expand yes -fill both/);
  $d->bind('<Return>' => [sub {1;}]);
  $ed->focus;
  if (main::ShowDialog($d) =~ /OK/) {
    $var=$ed->get('0.0','end');
    $d->destroy();
    return $var;
  } else {
    $d->destroy();
    return undef;
  }
}

sub listQuery {
  my ($select_mode,$vals,$selected)=@_;
  my $top=ToplevelFrame();

  my $d=$top->DialogBox(-title	  => "Select attributes to compare",
			-width	  => '8c',
			-buttons  => ["OK", "Cancel"]);
  $d->bind('all','<Escape>'=> [sub { shift; 
				     shift->{selected_button}='Cancel'; 
				   },$d ]);
  my $l=$d->Scrolled(qw/Listbox -relief sunken 
                        -takefocus 1
                        -scrollbars e/,
		     -selectmode => $select_mode,
		     -height=> min($main::maxDisplayedValues,scalar(@$vals))
		    )->pack(qw/-expand yes -fill both/);
  $l->insert('end',@$vals);
  $l->BindMouseWheelVert();
  my $act=0;
  my %selected = map { $_ => 1 } @$selected;
  for ($a=0;$a<@$vals;$a++)  {
    if ($selected{$$vals[$a]}) {
      $l->selectionSet($a);
      if (not $act) {
	$act=1;
	$l->activate($a);
	$l->see($a);
      }
    }
  }
 $l->focus;
 my $result= &main::ShowDialog($d,$l,$top);

 if ($result=~ /OK/) {
   @$selected=();
   foreach (0 .. $l->size-1) {
     push @$selected, $$vals[$_] if $l->selectionIncludes($_);
   }
   $d->destroy;
   return 1;
 }
 $d->destroy;
 return 0;  
}


package Tectogrammatic;

use base qw(TredMacro);
import TredMacro;

#include tr_common.mak

# binding-context TR_Diff
#include contrib/trdiff.mak
