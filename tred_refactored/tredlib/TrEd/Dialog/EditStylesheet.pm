package TrEd::Dialog::EditStylesheet;

use strict;
use warnings;

use TrEd::Config;
# potom prerobit na TrEd::Stylesheets asi
use TrEd::Utils;
use TrEd::MinMax qw{first};
use TrEd::Basics qw{$EMPTY_STR};
use TrEd::ValueLine;

use Data::Dumper;

use Readonly;

Readonly my $HELP => <<'EOF';
H<Stylesheet quick help>

I<This dialog allows you to edit the current display stylesheet.>

I<A stylesheet consists of PATTERNS (as described below) which influence the overall tree appearance as well as visual representation of individual nodes, edges and labels (including label content).>

I<A pattern can represent one line of a label of a node or an edge, define a per-node text to appear in the text line above the tree, and/or provide styling information for the node and its edges, e.g. the shape, color, line thickness, line style, etc.>

I<See the >L<User's manual#stylesheets>I< for more details.>

H<Pattern syntax>

B<PATTERN:> C<&lt;prefix&gt;:&lt;rules&gt;>

B<Default prefixes:>
  C<context    >- restrict stylesheet to contexts matching given regexp
  C<node       >- define a node label (default if no prefix given)
  C<edge       >- define an edge label
  C<style      >- define node and edge appearance (for individual nodes)
  C<rootstyle  >- define node and edge appearance globally
  C<text       >- define per-node value-line text
  C<hint       >- renders to text displayed in a node's tooltip

B<Rules interpolation:>
  C<${attribute}    >- interpolates to the attribute value
  C<#{color}        >- applies given font color to the rest of the label

  C<&lt;? perlcode ?&gt;>  - evaluates Perl code and interpolates the result.
                    C<$this> - the node the label or style applies to
                    C<$root> - root of the tree
                    C<$${attribute}> - like C<"$this-&gt;{attribute}">

  any other text - interpolates to itself

H<Root Styles>

B<SYNTAX:>  C<#{name:value}> or C<#{name}>


  C<balance             >- #{balance:1} draws a balanced rather than ordered tree;
  C<                    >  #{balance:spread} is the same but projective on leafs (useful e.g. for Penn Treebank)
  C<vertical            >- draw the tree L<vertically#vertical-mode>
  C<baseXPos            >- X-coordinate of the root node
  C<baseYPos            >- Y-coordinate of the root node
  C<nodeXSkip           >- default horizontal skip between nodes
  C<nodeYSkip           >- default vertical skip between nodes
  C<lineSpacing         >- line-spacing coeficient in text labels (Default: 1)
  C<skipHiddenParents   >- connect nodes with hidden parents to nearest
  C<                    >  displayed ancestors
  C<skipHiddenLevels    >- display nodes with hidden parents one level below their nearest
  C<                    >  displayed ancestors (implies C<skipHiddenParents>)
  C<labelsep            >- space between node and label in vertical mode
  C<columnsep           >- space between columns in vertical mode
  C<columnsep[i]        >- space before i-th column in vertical mode
  C<stackOrder          >- comma separated list of item tags defining a z-axis
                           ordering of canvas items (lowest first)

H<Styles>

B<SYNTAX:>  C<#{object-feature:value}>

B<Object features> (by category)

U<Hiding nodes>
  C<Node-hide           >- if non-zero, do not display the node at all
  See also C<skipHiddenParents> and C<skipHiddenLevels> rootstyles.

U<Shape>
  C<Node-shape          >- oval, rectangle, polygon
  C<Node-polygon        >- relative coordinates of the poligon points

U<Colors>
  Colors can be specified either by name (such as 'red', 'lightblue', etc.), or
  by a hex RGB string of the form #RRGGBB.

  C<Oval-fill           >- color to fill a node shape with
  C<Oval-outline        >- color of the outline of node shape
  C<CurrentOval-fill    >- color to fill the shape of an active node with
  C<CurrentOval-outline >- color of the outline of the shape of the active node
  C<Line-fill           >- color of the edge (see U<Edges>)

  C<Oval-dash           >- pattern for the outline of the node shape
  C<                    >  (oval/rectangle/polygon)
  C<CurrentOval-dash    >- pattern for the outline of the active node shape
  C<Oval-dashoffset     >- starting offset for the outline pattern

U<Size>
  C<Node-width          >- set shape width to the given amount
  C<Node-height         >- set shape height to the given amount
  C<Oval-width          >- width of the outline of a node shape
  C<CurrentOval-width   >- width of the outline of an active node shape
  C<Node-addwidth       >- add to shape width by given amount
  C<Node-addheight      >- add to shape height by given amount
  C<Node-currentwidth   >- set shape width for active node
  C<Node-currentheight  >- set shape height for active node

U<Position and level>
  C<Node-addbeforeskip  >- skip before: 10, 2c, 12pt, etc.
  C<Node-addafterskip   >- skip after
  C<Node-rellevel       >- alter vertical leveling of the subtree
  C<Node-level          >- alter vertical leveling of a single node
  C<NodeLabel-skipempty >- skip empty node labels
  C<EdgeLabel-skipempty >- skip empty edge labels
  C<NodeLabel-yadj      >- adjust vertical position of node labels by given amount
  C<EdgeLabel-yadj      >- adjust vertical position of edge labels by given amount
  C<EdgeLabel-coords    >- custom edge label position. Default: (n+p)/2,(n+p)/2

U<Alignment>
  C<Node-textalign      >- alignment of labels within label-box (right,left,center)
  C<Node-textalign[i]   >- alignment of i-th label within label-box (right,left,center)
  C<NodeLabel-valign    >- only as rootstyle. Values: top, center, bottom.
  C<NodeLabel-halign    >- left, right, center
  C<Edge-textalign      >- alignment of edge labels within label-box (right,left,center)
  C<EdgeLabel-halign    >- values: right, center, left
  C<EdgeLabel-valign    >- values: top, center, bottom

U<Edges (lines)>
  C<Line-coords         >- coordinations of the edge(s) to be drawn.
  C<                    >  Default: n,n,p,p (see the L<documentation#Line-coords>)
  C<                    >  May consist of more &-separated segments.
  C<Line-arrow          >- side of an edge to put an arrow on: first, both, last
  C<Line-smooth         >- 1 if the line should be drawn as a curve, 0 otherwise.
  C<Line-tag            >- tags passed to line_click_hook (see the L<documentation#Line-tag>)
  C<Line-hint           >- text to show when pointer hovers over the line (see the L<documentation#Line-hint>)
  C<Line-...            >- where C<...> is any of C<dash>, C<activedash>, C<dashoffset>,
  C<                    >  C<fill>, C<activefill>, C<width>, and C<activewidth>
  C<                    >  specifying visual properties of edges. Values and
  C<                    >  semantics are similar to those of C<Oval-...>.
  C<                    >  Values for individual line segments are &-separated.

U<Boxes around labels>
  C<NodeLabel-dodrawbox >- force drawing a box around labels: (yes,no)
  C<NodeLabel-nodrawbox >- force disabling a box around node label: (yes,no)
  C<EdgeLabel-dodrawbox >- force drawing a box around edge labels: (yes,no)
  C<EdgeLabel-nodrawbox >- force disabling a box around node label: (yes,no)
  C<TextBox-...         >- where C<...> is any of C<dash>, C<activedash>,
  C<                    >  C<dashoffset>, C<fill>, C<activefill>, C<outline>, 
  C<                    >  C<activeoutline>, <width>, C<activewidth>
  C<                    >  (see the L<documentation#TextBox> for details)
  C<EdgeTextBox-...     >- similar, see the L<documentation#EdgeTextBox>
  C<CurrentTextBox-...  >- options specific for Text Box of the current node
  C<CurrentEdgeTextBox..>- options specific for Edge Box of the current node
  C<Text[...]-..        >- see the L<documentation#Textposition-fill>
  C<TextBg[...]-..      >- see the L<documentation#TextBg>
EOF

# functions from main namespace
# extract callbacks...
sub tred_pod_add_tags {
  my ($grp,$w)=@_;
  $w->tag(qw(configure link -font C_default -foreground blue));
  $w->tag(qw(configure link_hover -underline 1));

  $w->tagBind('link', '<Any-Enter>' =>
		sub {
		  my $w = shift;
		  my $idx = $w->index($w->XEvent->xy);
		  my ($start,$end) = $w->tagPrevrange('link',$idx);
		  if ($start eq $EMPTY_STR) {
		    ($start,$end) = $w->tagNextrange('link',$idx);
		  }
		  if ($start ne $EMPTY_STR) {
		    $w->tagAdd('link_hover', $start,$end);
		  }
		}
	     );
  $w->tagBind('link_hover', '<Any-Leave>' =>
		sub {
		  shift->tagRemove('link_hover','0.0','end')
		}
	     );
  $w->tagBind(qw(link <1>) => sub {
		my $w = shift;
		my $Ev = $w->XEvent;
		my $idx = $w->index($Ev->xy);
		if ($idx ne $EMPTY_STR) {
		  my $sect = first {/^#/} $w->tagNames($idx);
		  if ($sect) {
		    $sect =~ s/^#//;
		    $w->toplevel->Deactivate;
		    main::help_topic($w,$sect);
		  }
	        }
	      }
	     );

  $w->tag(qw(configure underlined -font C_default -underline 1));
  $w->tag(qw(configure heading -font C_heading));
  $w->tag(qw(configure bold -font C_bold));
  $w->tag(qw(configure fixed -font C_fixed));
  $w->tag(qw(configure default -font C_default));
  $w->tag(qw(configure italic -font C_italic));
}

# stylesheet
sub _sytylesheetInsertAttr {
  my ($e,$name,$using_this) = @_;
  my @tags = $e->tagNames('insert');
  
  # work around ends of lines where no tags appear
  # look one char back and if we are not after an end-of-code ?>, we take the tags from there

  my $startline = length($e->get('insert linestart','insert'))==0 ? 1 : 0;
  my $endline = length($e->get('insert','insert lineend'))==0 ? 1 : 0;
  my @one_before_idx = ('insert - '.(1+$startline).' chars','insert'.($startline ? ' - 1 chars' : ''));
  my @two_before_idx = ('insert - '.(2+$startline).' chars','insert'.($startline ? ' - 1 chars' : ''));
  my @one_after_idx =  ('insert'.($endline ? ' + 1 chars' : ''),'insert + '.(1+$endline).' chars');

  my $before = 0;
  if (!@tags and ($e->get(@two_before_idx) ne '?>' and
	first { $_ eq 'Code' } $e->tagNames($one_before_idx[0]))) {
    @tags = $e->tagNames($one_before_idx[0]);
  }
    
  my $str;
  if ( first { /^(?:Code|CAttribute|Variable)$/ } @tags ) {
    $str= $using_this ? q{$this->attr('}.$name.q{')} : '$${'.$name.'}';
    if (  first { /^(?:CAttribute|Variable|QString|String)$/ } $e->tagNames($one_before_idx[0]) ) {
      $str = '.' . $str;
    }
    if (  first { /^(?:CAttribute|Variable|QString|String)$/ } $e->tagNames($one_after_idx[0]) ) {
      $str .= '.';
    }
  }
  elsif  ( first {/^(?:QString|QAttribute|QStyle)$/} @tags ) {
    $str= $using_this ? q{".$this->attr('}.$name.q{')."} : '\\${'.$name.'}' ;
  }
  else {
    $str='${'.$name.'}';    
  }
  $e->Insert($str);    

  # Insert should be equivalent to previously used
  #  $e->delete('sel.first','sel.last') 
  #    if ($e->tagNextrange('sel','0.0'));
  #  $e->insert('insert',$str);
}

sub format_tred_pod {
  map {
    if (/^([HUBICQ])<(.[^>]*)>/) {
      my $style;
      if ($1 eq 'B') {
	$style = 'bold';
      } elsif ($1 eq 'I') {
	$style = 'italic';
      } elsif ($1 eq 'C') {
	$style = 'fixed';
      } elsif ($1 eq 'U') {
	$style = 'underlined';
      } elsif ($1 eq 'H') {
	$style = 'heading';
      } else {
	$style = 'default';
      }
      my $l = $2;
      $l=~s/&lt;/\</g;
      $l=~s/&gt;/\>/g;
      ($l,$style)
    } elsif (/^L<(.[^>]*)>/) {
      my $l = $1;
      $l=~s/&lt;/\</g;
      $l=~s/&gt;/\>/g;
      my ($t,$sec)=split /#/,$l,2;
      ($t,['link','#'.$sec])
    } else {
      my $l=$_;
      $l=~s/&lt;/\</g;
      $l=~s/&gt;/\>/g;
      ($l,'default')
    }} split /([HUBILCQ]<.[^>]*>)/,$_[0]
}


sub preview_stylesheet {
  my ($win, $grp, $e, $preview_applied_ref) = @_;
       
  ${$preview_applied_ref} = 1;
  my ($hint,$context,$patterns) = TrEd::Utils::getStylesheetPatterns($win);
  
  TrEd::Utils::setStylesheetPatterns($win,$e->get('0.0','end'));
  TrEd::ValueLine::update($grp);
  if ($win->{stylesheet} eq TrEd::Utils::STYLESHEET_FROM_FILE()) {
    main::get_nodes_fsfile($grp,$win->{FSFile});
    main::redraw_fsfile($grp,$win->{FSFile});
  } else {
    main::get_nodes_stylesheet($grp,$win->{stylesheet});
    main::redraw_stylesheet($grp,$win->{stylesheet});
  }
  TrEd::Utils::setStylesheetPatterns($win,[$hint,$context,$patterns]);
}

# stylesheet, dialog, UI
#TODO: needs refactoring
sub show_dialog {
  my ($grp) = @_;
  my $win = $grp->{focusedWindow};
  my $hook_result = main::doEvalHook($win,"customize_attrs_hook");
  # return if (defined $hook_result and $hook_result eq 'stop');
  return if ($hook_result eq 'stop');

  return if not ($win->treeView()->patterns() or $win->{FSFile});

  $grp->{top}->Busy(-recurse => 1);
  # STYLESHEET_FROM_FILE is from TrEd::Utils
  my @buttons = ('OK', ($win->{FSFile} ? 'Preview' : ()),
	    (($win->{FSFile} and $win->{stylesheet} ne TrEd::Utils::STYLESHEET_FROM_FILE()) ? 'Store to current file' : ()),
		 'Cancel');
  my $edit_dialog=$grp->{top}->
    DialogBox(-title=> 'Stylesheet editor',
              -width=> '10c',
              -buttons=> \@buttons
             );

  foreach my $button (@buttons) {
    $edit_dialog->Subwidget("B_$button")->configure(-underline => 0);
  }
  $edit_dialog->Subwidget('top')->configure(qw(-takefocus 0));
  $edit_dialog->Subwidget('bottom')->configure(qw(-takefocus 0));

  # Pattern Editor
  my $eff = $edit_dialog->Frame(qw/-relief sunken -bd 1 -takefocus 0/)->
    pack(qw/-padx 3 -pady 3 -side top -fill x/);

  my $elabff=$edit_dialog->Frame->pack(-in => $eff, qw/-padx 3 -pady 3 -side top -fill x/);

  # will be used later
  my @text_opt = 
   eval { require Tk::CodeText; require Tk::CodeText::TrEdStylesheet }
     ? (qw(CodeText -syntax TrEdStylesheet), -indentchar => '  ')
 : eval { require Tk::TextUndo }
   ? qw(TextUndo)
 : qw(Text);

  $elabff->Label(-text => "Here you can edit the current display stylesheet (press ^I to insert tab, ^L to clear"
		   .($text_opt[0] eq 'CodeText' ? ", ^Z to undo" : $EMPTY_STR).")     ",
		 -anchor => 'nw', -justify => 'left')->pack(qw/-side left/);
  my $helplabel = $elabff->Label(-text => "Help",
			    -underline => 0,
			    -anchor => 'nw', -justify => 'left')
    ->pack(qw/-side right/);

  

  require Tk::HelpTiptool;
  my $help = $edit_dialog->HelpTiptool(-background => '#ffffbb',
			     -troughcolor => '#cccc99',
			     -message=> [format_tred_pod($HELP)]
			    );
  tred_pod_add_tags($grp,$help->Subwidget('text'));
  $edit_dialog->bind('<Alt-h>', sub { $help->Toggle($helplabel); });
  $help->bind('<Alt-h>', sub { $help->Toggle($helplabel); });

  $helplabel->bind('<Button>', sub { $help->Toggle($helplabel); });
  # All wrapping frame with attribute selection and buttons
  my $f = $edit_dialog->Frame(qw/-relief sunken -bd 1 -takefocus 0/);
#  $f->Frame(qw/-height 6 -takefocus 0/)->pack(qw/-side bottom/);
  # Frame with pattenrs listbox
  my $cf = $f->Frame(qw(-takefocus 0));

  # @text_opt defined few paragraphs above
  my $e = $cf->Scrolled(@text_opt, 
		       qw/-scrollbars osoe -height 35
			  -relief sunken -borderwidth 2/);
  my $edit = $e->Subwidget('scrolled');
  main::_deleteMenu($edit->menu(),'File');
  if ($text_opt[0] eq 'CodeText') {
    $edit->bindtags([$edit,ref($edit),$edit->toplevel(),'all']);
    $edit->bind('<Tab>', sub { shift->focusNext(); Tk->break() });
    my $syntax = $edit->menu->entrycget('View','-menu')->entrycget('Syntax','-menu');
    my $last = $syntax->index('last');
    if ($last ne 'none') {
      $syntax->delete($_) for grep { defined and !/^(None|Perl|TrEdStylesheet)$/ }
	map { eval { local $SIG{__DIE__}; $syntax->entrycget($_,'-label')} } 0..$last
    }
    $edit->menu->entrycget('View','-menu')->delete('Rules Editor');
  }

  main::disable_scrollbar_focus($e);
  
  my $preview_applied;
  # the preview command
  if ($edit_dialog->Subwidget('B_Preview')) {
    $edit_dialog->Subwidget('B_Preview')->configure(
      -command => [\&preview_stylesheet, $win, $grp, $e, \$preview_applied]);
  }
  # Frame with attribute selection
  my $af;
  my @atord=();
  my $attrs = main::doEvalHook($win,"get_node_attrs_hook",'edit_stylesheet');
  if (ref($attrs)) {
    @atord = @$attrs;
  } else {
    if ($win->{FSFile}) {
      if (TrEd::Basics::fileSchema($win->{FSFile})) {
	@atord = TrEd::Basics::fileSchema($win->{FSFile})->attributes();
      } else {
	@atord = $win->{FSFile}->FS->attributes;
      }
    }
    if ($TrEd::Config::sortAttrs) {
      @atord=sort {uc($a) cmp uc($b)} @atord
	unless (main::doEvalHook($win,"sort_attrs_hook",\@atord,'',undef));
    }
  }

  if (@atord) {
    $af = $f->Frame(qw(-takefocus 0));
    #  $af->Frame(qw/-height 15 -takefocus 0/)->pack();
    # Attributes listbox
    $af->Label(qw/-text Attributes -underline 0 -anchor nw -justify left/)->pack(qw/-fill both/);
    my $al= $af->Scrolled(qw/Listbox
			     -bg white
			     -width 0
			     -relief sunken
			     -borderwidth 2 -setgrid true
			     -scrollbars oe
			     -exportselection 0/)->pack(qw/-pady 3 -expand yes -fill y/);
    $edit_dialog->bind('<Alt-a>', [$al,'focus']);
    main::disable_scrollbar_focus($al);
    $al->BindMouseWheelVert();
    
    $al->insert('end',@atord);
    if (@atord) {
      $al->activate(0);
      $al->selectionSet(0);
    }
    
    $af->pack(qw/-padx 5 -side left -fill y/) if $af;
    $al->bind('<Double-1>'=>
		[sub {
		   _sytylesheetInsertAttr($e,$al->get('active'));
		   $e->focus();
		   Tk->break();
		 }]
	       );
    $al->bind('<Shift-Double-1>'=>
		[sub {
		   _sytylesheetInsertAttr($e,$al->get('active'),1);
		   $e->focus();
		   Tk->break();
		 }]
	       );
    $al->bind('<space>'=>
		[sub {
		   _sytylesheetInsertAttr($e,$al->get('active'));
		   Tk->break();
		 }]
	       );
    $al->bind('<Return>'=>
		[sub {
		   _sytylesheetInsertAttr($e,$al->get('active'));
		   $e->focus();
		   Tk->break();
		 }]
	       );
  }

  {
    my $patterns=TrEd::Utils::getStylesheetPatterns($win);
    chomp $patterns;
    $e->insert('0.0',$patterns."\n");
  }
  $e->pack(qw/-padx 3 -pady 3 -side top -expand yes -fill both/);
  $e->TextSearchLine(-parent => $cf,-label=>'S~earch',
		     -prev_img => main::icon($grp,'16x16/up'),
		     -next_img => main::icon($grp,'16x16/down'),
		    )->pack(qw(-fill x -side bottom));

  $cf->pack(qw/-padx 5 -side left -expand yes -fill both/);


  $f->pack(qw/-padx 3 -pady 3 -side top -expand yes -fill both/);

  $edit_dialog->bind($edit_dialog,'<Tab>',['focusNext']);
  $edit->bindtags([$edit,ref($edit),$edit->toplevel,'all']);
  $edit->bind('<Control-l>',sub {$_[0]->delete('0.0','end'); Tk->break; });
  $edit->bind('<Tab>',sub { shift->focusNext; Tk->break });
  $edit_dialog->bind($edit_dialog,'<Shift-Tab>',sub { shift->focusPrev; Tk->break });
  $edit_dialog->bind($edit_dialog,'<Shift-ISO_Left_Tab>',sub { shift->focusPrev; Tk->break });
  $edit->bind('<Return>',sub{ shift->Insert("\n"); Tk->break; });
  $edit->bind(ref($edit),'<Control-Return>','NoOp');
  $edit_dialog->bind($edit,'<Control-Return>','NoOp');
  $edit_dialog->bind('<Escape>'=> [sub{ 
			   my ($w,$dlg,$hlp)=@_;
			   if ($hlp->isActive) {
			     $hlp->Deactivate();
			   } else {
			     $dlg->afterIdle(sub{ $dlg->{selected_button} = 'Cancel' });
			   }
			   Tk->break();
			 },$edit_dialog,$help]);
  $edit_dialog->BindReturn();
  $edit_dialog->protocol('WM_DELETE_WINDOW' => [sub { $_[0]->{selected_button} = 'Cancel' }, $edit_dialog]);
  $edit_dialog->BindButtons;
  $e->focus();
  $grp->{top}->Unbusy();
  my $result= main::ShowDialog($edit_dialog,$e,$grp->{top});
  if ($result eq 'Store to current file') {
    main::switchStylesheet($grp, TrEd::Utils::STYLESHEET_FROM_FILE());
    $grp->{selectedStylesheet} = TrEd::Utils::STYLESHEET_FROM_FILE();
    $win->{FSFile}->notSaved(1);
    $result = 'OK';
  }
  if ($result=~ /OK/) {
    TrEd::Utils::setStylesheetPatterns($win,$e->get('0.0','end'));
    TrEd::Utils::updateStylesheetMenu($grp);
    if ($win->{stylesheet} eq TrEd::Utils::STYLESHEET_FROM_FILE()) {
      $win->{FSFile}->notSaved(1);
    } else {
      TrEd::Utils::save_stylesheet_file($grp, $TrEd::Utils::default_stylesheet_path, $win->{stylesheet});
    }
    main::get_nodes_fsfile($grp,$win->{FSFile});
    TrEd::ValueLine::update($grp);
    if ($win->{stylesheet} eq TrEd::Utils::STYLESHEET_FROM_FILE()) {
      main::redraw_fsfile($grp,$win->{FSFile});
    } else {
      main::redraw_stylesheet($grp,$win->{stylesheet});
    }
  } elsif ($preview_applied) {
    main::get_nodes_fsfile($grp,$win->{FSFile});
    if ($win->{stylesheet} eq TrEd::Utils::STYLESHEET_FROM_FILE()) {
      main::redraw_fsfile($grp,$win->{FSFile});
    } else {
      main::redraw_stylesheet($grp,$win->{stylesheet});
    }
  }
  $edit_dialog->destroy();
  undef $edit_dialog;
}

1;