## This is macro file for Tred                                 -*-cperl-*-
## author: Petr Pajas
## created: Wed Mar 15 14:50:16 CET 2000

package TredMacro;

require TrEd::Query::List;
require TrEd::Query::String;
require TrEd::Dialog::FocusFix;

use strict;
use warnings;


use TrEd::Macros;
use vars qw{$libDir $grp $root $this $_NoSuchTree $Redraw $stderr $stdout
		     $forceFileSaved $FileChanged $FileNotSaved $NodeClipboard $nodeClipboard @AUTO_CONTEXT_GUESSING};


#test Bind \&Find => { key => 'F3', menu => 'Find', changing_file => 0 };
sub Find_nochange { Find(@_); ChangingFile(0) }


sub FindNext_nochange { FindNext(@_); ChangingFile(0); }


sub FindPrevious_nochange { FindPrev(@_); ChangingFile(0); }


sub CopyValues_nochange { CopyValues(@_); ChangingFile(0); }

sub PrevTree_nochange { PrevTree(@_); ChangingFile(0); }

sub NextTree_nochange { print STDERR "NextTree_nochange\n"; NextTree(@_); ChangingFile(0); }

sub TiePrevTree_nochange { TiePrevTree(@_); ChangingFile(0); }

sub TieNextTree_nochange { TieNextTree(@_); ChangingFile(0); }


sub CutToClipboard {
  return unless ($this and $this->parent);
  $nodeClipboard=$this;
  $this=$this->rbrother ? $this->rbrother : $this->parent;
  CutNode($nodeClipboard);
}


sub PasteFromClipboard {
  return unless ($this and $nodeClipboard);
  unless ($this->test_child_type($nodeClipboard)) {
    if (GUI()) {
      return unless
	QuestionQuery('Incompatible node type',"WARNING: the current node does not permit the node in clipboard ".
			"as a child.\nThe resulting tree will be invalid.",
		      "Don't paste","Paste anyway") eq "Paste anyway";
    }
    warn "PasteFromClipboard: incompatible node type - pasting anyway\n"
  }
  PasteNode($nodeClipboard,$this);
  $this=$nodeClipboard;
  $nodeClipboard=undef;
}

# this subroutine's name collides with one that exists in TrEd's main namespace
sub QueryString {
  ## display a dialog box with an edit line and Ok/Cancel buttons
  ## parameters: window title, entry label, default value

  TrEd::Query::String::new_query($grp->{framegroup},@_);
}

*StringQuery = \&QueryString;

sub EditBoxQuery {
  ## draws a dialog box with one Text widget and Ok/Cancel buttons
  ## expects dialog title and default text
  ## returns text of the Text widget
  my $d;
  my $ed;

  my ($title,$text,$hintText,$opts)=@_;
  $opts ||={};

  $d=ToplevelFrame()->DialogBox(-title => $title,
			   -buttons => delete($opts->{-buttons}) || ["OK","Cancel"]);
  main::addBindTags($d,'dialog');
  $d->bind('all','<Tab>',sub { shift->focusNext; });
  $d->bind('all','<Shift-Tab>',sub { shift->focusPrev; });
  if ($hintText) {
    my $t=$d->add(qw/Label -wraplength 6i -justify left -text/,$hintText);
    $t->pack(qw/-padx 0 -pady 0 -expand 0 -fill x/);
  }
  my @opts = (qw/-relief sunken -scrollbars se -borderwidth 2/,-font => $main::font,
	      -height => ($opts->{-height}||8)
	     );
  if (!$opts->{-widget} or !eval { $ed=$d->Scrolled(@{$opts->{-widget}},@opts); }) {
    $ed=$d->Scrolled('Text',@opts);
  }
  $ed->insert('0.0',$text);
  $ed->update;
  $ed->SetCursor($opts->{-cursor}) if $opts->{-cursor};
  eval { $ed->highlight('0.0','end') if $opts->{-highlight} };
  $ed->pack(qw/-padx 0 -pady 10 -expand yes -fill both/);
  $d->bind(ref($ed->Subwidget('scrolled')),'<Control-Return>' => sub {1;});
  $d->bind('<Return>' => sub {Tk->break;});
  $d->bind('<Control-Return>' => sub { shift->toplevel->{default_button}->Invoke; Tk->break;});
  $d->bind($d,'<Escape>', [sub { shift; shift->{selected_button}= 'Cancel'; },$d] );
  $d->bind('<Control-f>',[$ed,'FindPopUp']);
  $d->bind('<Control-r>',[$ed,'FindAndReplacePopUp']);
  $d->bind(ref($ed->Subwidget('scrolled')),'<Escape>', [sub { shift; my $w=shift; $w->{selected_button}= 'Cancel'; },$d] );
  $ed->focus;
  RunCallback($opts->{-init},$d,$ed) if $opts->{-init};
  if (TrEd::Dialog::FocusFix::show_dialog($d) =~ /OK/) {
    $text=$ed->get('0.0','end');
    chomp($text);
    $d->destroy();
    return $text;
  } else {
    $d->destroy();
    return;
  }
}

sub ListQuery {
  my ($title,$select_mode,$vals,$selected,$opts)=@_;
  $opts||={};
  my $top=delete($opts->{top}) || ToplevelFrame();
  TrEd::Query::List::new_query($top,$title,$select_mode,$vals,$selected,%$opts);
}

sub QuestionQuery {
  my $top;
  if (ref($_[0])) {
    $top = shift;
  } else {
    $top = ToplevelFrame();
  }
  my ($title, $message,@buttons) = @_;
  my $d = $top->DialogBox(-title => $title,
			  -buttons => [@buttons]);
  $d->add('Label', -text => $message, -font => StandardTredFont(), -wraplength => 240)->pack(-expand => 1, -fill => 'x');
  $d->bind('<Return>', sub { my $w=shift; my $f=$w->focusCurrent;
			     $f->Invoke if ($f and $f->isa('Tk::Button')) } );
  $d->bind($d,'<Escape>', [sub { shift; shift->toplevel->{selected_button}= 'Cancel' },$d] );
#    if grep { $_ eq 'Cancel' } @buttons;
  $d->bind('all','<Tab>',[sub { shift->focusNext; }]);
  my $ret = $d->Show;
  $d->destroy;
  return $ret;
}
*questionQuery=\&QuestionQuery;


sub PerlSearch {
  my $label= "Any inserted perl code will be evaluated for each node from current ".
  "as long as it ends with zero or undefined value; the first node for which ".
  "the code succeedes (returns defined non-zero value) will be selected.\n\n".
  "Use \`\$this\' to refer to the current node, \`\$root\' to the root of the tree.\n".
  "If \`\$n\' refers to some node, \`\$n->{attr}\' is its value of the attribute \`attr\'.\n".
  "The governor of a node \$n is \`\$n->parent\', nearest ".
  "left brother of \'\$n\' in the tree structure is \'\$n->lbrother\'".
  "the right brother of \$n is \`\$n->rbrother\'. The first son of \'\$n\' ".
  "is referred to as \`\$->firstson\'. If no such node exists, all these functions ".
  "return zero (\`0\') or possibly \`undef\'.".
  "NOTE: \$n->lbrother and \$n->rbrother are not necesserilly displayed on left of \$n\n\n".
  "Press Ctrl+Enter to start search\n"
    ;

  my @text_opt = eval { require Tk::CodeText; } ? (qw(CodeText -syntax Perl)) : qw(Text);
  my $script = EditBoxQuery("Search: insert perl expression:",$TrEd::MacroStorage::macPerlSearchScript,$label,
			    { -widget => \@text_opt,
			      -highlight => 1
			    }
			   );
  unless ($script) {
    $FileNotSaved=0;
    return;
  }
  chomp $script; $script.="\n";
  $TrEd::MacroStorage::macPerlSearchScript=$script;
  while ($this=$this->following or NextTree()) {
    last if eval($script);
    if ($@) {
      ErrorMessage($@);
      last;
    }
  };
}


sub PerlEval {
  my $label= <<EOF;
Insert perl code to evaluate.

Use:
\$this\t\t- to refer to the current node
\$root\t\t- to the root of the tree
\$n->{attr}\t- to refer to the attribute `attr' of node \$n
\$n->parent\t- to refer to \$n's parent
\$n->lbrother\t- to refer to \$n's nearest left sibling
\$n->rbrother\t- to refer to \$n's nearest right sibling
\$n->firstson\t- to refer to \$n's leftmost child node
\$n->children\t- to obtain a list of all \$n's child nodes
\$n->descendants\t- to obtain a list of all nodes in \$n's subtree

When finished, press Ctrl+Enter to execute your script.
EOF

  my @text_opt = eval { require Tk::CodeText; } ? qw(CodeText -syntax Perl) : qw(Text);
  my $script = EditBoxQuery("Insert perl expression:",$TrEd::MacroStorage::macPerlEvalScript,$label,
			    { -widget => \@text_opt,
			      -highlight => 1
			    });
  unless ($script) {
    $FileNotSaved=0;
    return;
  }
  chomp $script; $script.="\n";
  $TrEd::MacroStorage::macPerlEvalScript=$script;
  eval("package ".CurrentContext().";\n#line 1\n".$script);
  die $@ if $@;
}

sub RedrawAndUpdateThis {
  Redraw($grp,1);
  $Redraw='none';
  $this=$grp->{currentNode};
}


sub GotoTreeAsk {
  my $to=TrEd::Query::String::new_query($grp->{framegroup},"Give a Tree Number","Number");

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
  RedrawAndUpdateThis();
  ChangingFile(0);
}


sub GotoFileAsk {
  my $to=TrEd::Query::String::new_query($grp->{framegroup},"Give a File Number","Number");
  return unless $to=~/^\s*\d+\s*$/;
  if (GotoFileNo($to-1)) {
    $FileNotSaved = GetFileSaveStatus();
    RedrawAndUpdateThis();
  } else {
    ChangingFile(0);
  }
}



sub TieGotoTreeAsk {
  my $to=TrEd::Query::String::new_query($grp->{framegroup},"Give a Tree Number","Number");

  if ($to=~/#/) {
    for (my $i=$grp->{treeNo}+1; $i<=$grp->{FSFile}->lastTreeNo; $i++) {
      TieGotoTree($i+1), return if ($grp->{FSFile}->treeList->[$i]->{form} =~ $to);
    }
    for (my $i=0; $i<$grp->{treeNo}; $i++) {
      TieGotoTree($i+1), return if ($grp->{FSFile}->treeList->[$i]->{form} =~ $to);
    }
  } else {
    TieGotoTree($to) if defined $to;
  }
  RedrawAndUpdateThis();
  ChangingFile(0);
}

sub PerlSearchNext {
  if ($TrEd::MacroStorage::macPerlSearchScript) {
    while ($this=$this->following or NextTree()) {
      last if eval($TrEd::MacroStorage::macPerlSearchScript);
    }
  } else {
    PerlSearch();
  }
}


sub TieLastTree {
  ChangingFile(0);
  TieGotoTree($grp->{FSFile}->lastTreeNo+1);
  RedrawAndUpdateThis();
}


sub TieFirstTree {
  ChangingFile(0);
  TieGotoTree(1);
  RedrawAndUpdateThis();
}


sub LastTree {
  ChangingFile(0);
  GotoTree($grp->{FSFile}->lastTreeNo+1);
  RedrawAndUpdateThis();
}


sub FirstTree {
  ChangingFile(0);
  GotoTree(1);
  RedrawAndUpdateThis();
}


sub GotoNextNodeLin {
  ChangingFile(0);
  $Redraw='none';
  my $sentord=$grp->{FSFile}->FS->order;
  my $next=NextNodeLinear($this,$sentord);
  unless (HiddenVisible()) {
    while ($next and IsHidden($next)) {
      $next=NextNodeLinear($next,$sentord);
    }
  }
  $this=$next if $next;
}


sub GotoPrevNodeLin {
  ChangingFile(0);
  $Redraw='none';
  my $sentord=$grp->{FSFile}->FS->order;
  my $next=PrevNodeLinear($this,$sentord);
  unless (HiddenVisible()) {
    while ($next and IsHidden($next)) {
      $next=PrevNodeLinear($next,$sentord);
    }
  }
  $this=$next if $next;
}

sub RunCallback {
  my $sub = shift;
  no strict qw{refs};
  if (ref($sub) eq 'ARRAY') {
    my ($realsub,@args)=@$sub;
    &{$realsub}(@args,@_);
  } else {
    &$sub(@_);
  }
}

{
  my (@start_hooks,
      @init_hooks,
      @initialize_bindings_hooks,
      @exit_hooks,
      @open_file_hooks,
      @reload_macros_hooks);

  # the hook may be either a sub name, CODE ref or ARRAY ref, where
  # the first element of the array is the name/CODE-ref to execute
  # and the rest are arguments to be passed to it

  sub register_init_hook ($) {
    my ($hook)=@_;
    push @init_hooks,$hook;
  }
  sub unregister_init_hook ($) {
    my ($hook)=@_;
    @init_hooks=grep { $_ ne $hook } @init_hooks;
  }
  sub register_initialize_bindings_hook ($) {
    my ($hook)=@_;
    push @initialize_bindings_hooks,$hook;
  }
  sub unregister_initialize_bindings_hook ($) {
    my ($hook)=@_;
    @initialize_bindings_hooks=grep { $_ ne $hook } @initialize_bindings_hooks;
  }
  sub register_start_hook ($) {
    my ($hook)=@_;
    push @start_hooks,$hook;
  }
  sub unregister_start_hook ($) {
    my ($hook)=@_;
    @start_hooks=grep { $_ ne $hook } @start_hooks;
  }
  sub register_exit_hook ($) {
    my ($hook)=@_;
    push @exit_hooks,$hook;
  }
  sub unregister_exit_hook ($) {
    my ($hook)=@_;
    @exit_hooks=grep { $_ ne $hook } @exit_hooks;
  }
  sub register_open_file_hook ($) {
    my ($hook)=@_;
    push @open_file_hooks,$hook;
  }
  sub unregister_open_file_hook ($) {
    my ($hook)=@_;
    @open_file_hooks=grep { $_ ne $hook } @open_file_hooks;
  }
  sub register_reload_macros_hook ($) {
    my ($hook)=@_;
    push @reload_macros_hooks,$hook;
  }
  sub unregister_reload_macros_hook ($) {
    my ($hook)=@_;
    @reload_macros_hooks=grep { $_ ne $hook } @reload_macros_hooks;
  }
  sub init_hook {
    my @args = @_;
    foreach my $sub (@init_hooks) {
      return 'stop' if RunCallback($sub,@args) eq 'stop';
    }
    return;
  }
  sub initialize_bindings_hook {
    my @args = @_;
    foreach my $sub (@initialize_bindings_hooks) {
      return 'stop' if RunCallback($sub,@args) eq 'stop';
    }
    return;
  }
  sub start_hook {
    my @args = @_;
    foreach my $sub (@start_hooks) {
      return 'stop' if RunCallback($sub,@args) eq 'stop';
    }
    return;
  }
  sub open_file_hook {
    my @args = @_;
    foreach my $sub (@open_file_hooks) {
        my $callback_result = RunCallback($sub,@args);
        if(defined $callback_result && $callback_result eq 'stop'){
            return 'stop';
        }
    }
    return;
  }
  sub exit_hook {
    my @args = @_;
    foreach my $sub (@exit_hooks) {
      eval { RunCallback($sub,@args) };
      stderr($@) if $@;
    }
  }
  sub reload_macros_hook {
    my @args = @_;
    foreach my $sub (@reload_macros_hooks) {
      eval { RunCallback($sub,@args) };
      stderr($@) if $@;
    }
  }
}

sub node_menu_item_cget {
  my ($item,$opt)=@_;
  if ($grp->{framegroup}->{NodeMenu}) {
    $grp->{framegroup}->{NodeMenu}->entrycget($_,$opt);
  } else {
    return;
  }
}

sub configure_node_menu_items {
  my ($items, $config)=@_;
  if ($grp->{framegroup}{main_menu}) {
    my $tm = $grp->{framegroup}{main_menu};
    foreach my $key (@$items) {
      $tm->set_menu_options($key, @$config);
    }
  } else {
    if ($grp->{framegroup}->{NodeMenu}) {
      foreach (@$items) {
	$grp->{framegroup}->{NodeMenu}->entryconfigure($_,@$config);
      }
    }
  }
}

sub critical_node_menu_items {
  if ($grp->{framegroup}{main_menu}) {
    return [
      'MENUBAR:NODE:NEW_NODE',
      'MENUBAR:NODE:REMOVE_ACTIVE_NODE',
      'MENUBAR:TREE:INSERT_NEW_TREE_AFTER',
      'MENUBAR:TREE:INSERT_NEW_TREE_BEFORE',
      'MENUBAR:TREE:COPY_TREES',
      'MENUBAR:TREE:MOVE_CURRENT_TREE_BACKWARD',
      'MENUBAR:TREE:MOVE_CURRENT_TREE_FOREWARD',
      'MENUBAR:NODE:MAKE_CURRENT_NODE_THE_ROOT',
     ]
  } else {
    # old API
    return ["New Node",
	    "Remove Active Node",
	    "Insert New Tree",
	    "Insert New Tree After",
	    "Remove Whole Current Tree",
	    "Copy Trees ...",
	    "Move Current Tree Backward",
	    "Move Current Tree Foreward",
	    "Make Current Node the Root",
	   ];
  }
}

sub enable_node_menu_items {
  return unless $grp == $grp->{framegroup}{focusedWindow}; # we refuse to reconfigure this from non-focused window
  my $items = ref($_[0]) ? $_[0] : critical_node_menu_items();
  configure_node_menu_items($items,
			    [-state => 'normal']);
}
sub disable_node_menu_items {
  return unless $grp == $grp->{framegroup}{focusedWindow}; # we refuse to reconfigure this from non-focused window
  my $items = ref($_[0]) ? $_[0] : critical_node_menu_items();
  configure_node_menu_items($items,
			    [-state => 'disabled']);
}

sub _quick_pml_type {
  my $spec=shift;
  if (ref($spec) eq 'ARRAY') {
    if ($spec->[0] eq 'list') {
      q(<list>)._quick_pml_type($spec->[1]).q(</list>)
    } elsif ($spec->[0] eq 'alt') {
      q(<alt>)._quick_pml_type($spec->[1]).q(</alt>)
    } elsif ($spec->[0] eq 'structure') {
      q(<structure>).
	(join "\n",
	 map { qq(<member name="$spec->[2*$_+1]">)._quick_pml_type($spec->[2*$_+2]).q(</member>) }
	   0..int(($#$spec-1)/2)
	).qq(</structure>)
    } elsif ($spec->[0] eq 'choice') {
      q(<choice>).join("\n", map qq(<value>$_</value>), @$spec[1..$#$spec]).qq(</choice>)
    } else {
      die "quick_pml(): unknown or unsupported declaration type '$spec->[0]'";
    }
  } else {
    return qq(<cdata format="$spec"/>);
  }
}

sub QuickPML {
  my ($name,$spec,$root)=@_;
  my $template=_quick_pml_type($spec);
  my $pml = Treex::PML::Instance->load({string => <<"EOF"});
<$name xmlns="http://ufal.mff.cuni.cz/pdt/pml/">
<head>
  <schema>
   <pml_schema
     version="1.1"
     xmlns="http://ufal.mff.cuni.cz/pdt/pml/schema/">
     <root name="$name">
       $template
     </root>
   </pml_schema>
  </schema>
</head>
</$name>
EOF
  $pml->set_root($root) if $root;
  return $pml;
}


#ifinclude "contrib/contrib.mac"
############ ======================================= #########################
# this should be for TrEd only, not for btred and ntred...
# functions from contrib.mac, we still need to resolve auto-loading */contrib.mac


=pod

=head1 contrib.mac

contrib/contrib.mac - the file responsible for loading other macro files

=head2 DESCRIPTION

This file is included by default in tred.mac and serves as a wrapper
for other contributed macro package inclusions.

Besides it provides file_opened_hook and file_resumed_hook in the
package TredMacros. These hooks should not be overriden by other macro
packages. See below how to plug context-specific code in.



=cut


=pod

=head1 Context Guessing

=head2 @TredMacro::AUTO_CONTEXT_GUESSING

This global variable can be used by contributed TrEd macro packages to
plug-in their custom context guessing functions.  The purpose of such
a function is to detect whether the current file is suitable for the
macro package and if so, to indicate the correct binding context.

The function must return name of the context to switch to or undef if
the current file does not suit.

The synopsis for a package named 'Foo' is as follows:

  #binding-context Foo
  package Foo;
  BEGIN { import TredMacro; }
  context_guessing {
    my ($hook)=@_;
    if (PML::SchemaName() eq 'foo-data') { # some test that the file suites the macro package
      if ($hook eq 'file_opened_hook') {
         # some open-specific code
      } elsif ($hook eq 'file_resumed_hook') {
         # some resume-specific code
      }
      return 'Foo'; # return name of the macro package (context) to use
    }
    return;
  };

=cut

# ------------------------------------
# try guessing proper initial context
# ------------------------------------

use vars qw(@AUTO_CONTEXT_GUESSING);
use Carp;
sub context_guessing (&) {
  __context_guessing($_[0],0); # will push
}
sub priority_context_guessing (&) {
  __context_guessing($_[0],1); # will unshift
}
sub __context_guessing {
  my ($code,$priority)=@_;
  if (ref($code) eq 'CODE') {
    if ($priority) {
      unshift @TredMacro::AUTO_CONTEXT_GUESSING, $code;
    } else {
      push @TredMacro::AUTO_CONTEXT_GUESSING, $code;
    }
  } else {
    croak "Usage: context_guessing { .... };"
  }
}


sub guess_context_hook {
  my ($hook)=@_;
  my ($mode)= GetPatternsByPrefix('mode',STYLESHEET_FROM_FILE());
  return SwitchContext($mode) if defined $mode;
  return unless $grp->{FSFile};
  foreach my $sub (@TredMacro::AUTO_CONTEXT_GUESSING) {
    my $ret = &$sub;
    if (defined($ret)) {
      SwitchContext($ret);
      return $ret;
    }
  }
    no strict 'refs';
  # do not leave the current context unless it explicitly rejects the file
  my $context = CurrentContext();
  if (UNIVERSAL::can($context,'allow_switch_context_hook') and
      &{$context.'::allow_switch_context_hook'}() eq 'stop') {
    SwitchContext('TredMacro');
    SetCurrentStylesheet(STYLESHEET_FROM_FILE());
  }
  return;
}



#package TredMacro;
#binding-context TredMacro

sub init_tredmacro_bindings {
    # so the bindings would have some cotext set for the init phase
    # (during compilation) 
    TrEd::Macros::set_current_binding_contexts('TredMacro');
    
    ## add few custom bindings to predefined subroutines
    TrEd::Macros::bind_macro('Save', 'F2', 'Save File');
    TrEd::Macros::bind_macro('SaveAndPrevFile', 'F11', 'Save and Go to Previous File');
    TrEd::Macros::bind_macro('SaveAndPrevFile', 'L1');
    TrEd::Macros::bind_macro('SaveAndNextFile', 'F12', 'Save and Go to Next File');
    TrEd::Macros::bind_macro('SaveAndNextFile', 'L2');
    TrEd::Macros::bind_macro('PrevFile', 'Shift+F11', 'Go to Previous File');
    TrEd::Macros::bind_macro('PrevFile', 'Shift+L1');
    TrEd::Macros::bind_macro('NextFile', 'Shift+F12', 'Go to Next File');
    TrEd::Macros::bind_macro('NextFile', 'Shift+L2');
    
    TrEd::Macros::bind_macro('Find_nochange', 'F3', 'Find');
    
    TrEd::Macros::bind_macro('FindNext_nochange', 'F4', 'Find Next');
    
    TrEd::Macros::bind_macro('FindPrevious_nochange', 'Shift+F4', 'Find Previous');
    
    TrEd::Macros::bind_macro('NewRBrother', 'F7', 'New Node (r-brother)');
    TrEd::Macros::bind_macro('NewSon', 'Shift+F7', 'New Node (son)');
    TrEd::Macros::bind_macro('DeleteThisNode', 'F8', 'Delete Node');
    TrEd::Macros::bind_macro('CopyValues_nochange', 'F5', 'Copy Values');
    
    TrEd::Macros::bind_macro('PasteValues', 'F6', 'Paste Values');
    TrEd::Macros::bind_macro('PrevTree_nochange', 'comma', 'Previous Tree');
    
    TrEd::Macros::bind_macro('NextTree_nochange', 'period', 'Next Tree');
    
    TrEd::Macros::bind_macro('TiePrevTree_nochange', 'Ctrl+comma', 'Previous Tree (Tied)');
    TrEd::Macros::bind_macro('TieNextTree_nochange', 'Ctrl+Next', 'Next Tree (Tied)');
    
    TrEd::Macros::bind_macro('TieNextTree_nochange', 'Ctrl+period', 'Next Tree (Tied)');
    TrEd::Macros::bind_macro('TiePrevTree_nochange', 'Ctrl+Prior', 'Previous Tree (Tied)');
    
    TrEd::Macros::bind_macro('CutToClipboard', 'Ctrl+Insert', 'Cut Subtree');
    
    TrEd::Macros::bind_macro('PasteFromClipboard', 'Shift+Insert', 'Paste Subtree');
    
    TrEd::Macros::bind_macro('PerlSearch', 'Alt+H', 'Perl-Search');
    
    TrEd::Macros::bind_macro('PerlEval', 'Alt+e', 'Perl-Eval');
    
    TrEd::Macros::bind_macro('GotoTreeAsk', 'Alt+g', 'Go to...');
    
    TrEd::Macros::bind_macro('GotoFileAsk', 'Alt+G', 'Go to file...');
    
    TrEd::Macros::bind_macro('TieGotoTreeAsk', 'Ctrl+Alt+g', 'Go to... (tied)');
    TrEd::Macros::bind_macro('PerlSearchNext', 'Ctrl+Alt+H', 'Perl-Search Next');
    TrEd::Macros::bind_macro('TieLastTree', 'Ctrl+End', 'Go to last tree (tied)');
    TrEd::Macros::bind_macro('TieFirstTree', 'Ctrl+Home', 'Go to first tree (tied)');
    TrEd::Macros::bind_macro('LastTree', 'End', 'Go to last tree');
    TrEd::Macros::bind_macro('LastTree', 'greater');
    TrEd::Macros::bind_macro('FirstTree', 'Home', 'Go to first tree');
    TrEd::Macros::bind_macro('FirstTree', 'less');
    TrEd::Macros::bind_macro('GotoNextNodeLin', 'Ctrl+greater', 'Next node linearly');
    TrEd::Macros::bind_macro('GotoPrevNodeLin', 'Ctrl+less', 'Prev node linearly');
}

TrEd::Macros::set_current_binding_contexts('TredMacro');


1;
