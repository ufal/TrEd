package TrEd::List::Macros;

use strict;
use warnings;

use Tk;
use TrEd::Macros;
use TrEd::MinMax;
use TrEd::Utils qw{$EMPTY_STR};

# macro, menu, UI
sub create_list {
  my ($grp,$parent_w,$context_ref,$style_opts)=@_;
  my $t= $parent_w->Scrolled(qw/HList -columns 3
				-selectmode browse
				-header 1
				-relief sunken 
				-scrollbars ose/,
			    );
  $style_opts||={};
  my $style = $t->{default_style_text}=$t->ItemStyle(
    'text', %$style_opts
   );
  
  main::disable_scrollbar_focus($t);
  $t->BindMouseWheelVert();
  $t->header(create=>0,-itemtype=>'text',-borderwidth=>1, -relief=>'flat',-style=>$style,-text=>'Key');
  $t->header(create=>1,-itemtype=>'text',-borderwidth=>1, -relief=>'flat',-style=>$style,-text=>'Perl');
  $t->header(create=>2,-itemtype=>'text',-borderwidth=>1, -relief=>'flat',-style=>$style,-text=>'Name');
  $t->columnWidth(0,$EMPTY_STR);
  $t->columnWidth(1,0);
  $t->columnWidth(2,$EMPTY_STR);
  $t->anchorSet('0') if $t->info(exists => '0');
  $t->configure(-width=> 0);
  my $callback
    = [
       sub {
	 my ($w,$grp,$t,$ctxt)=@_;
	 my $macro = $t->info( data => $t->info('anchor') );
	 if (ref($macro) eq 'Tk::Callback') { # CODE ref gets mangled to Tk::Callback by Tk
	   $macro=$macro->[0];
	 }
	 #TODO: vyriesit volanie doEvalMacro
	 main::doEvalMacro($grp->{focusedWindow},$macro);
       },$grp,$t,$context_ref,
      ];
  $t->bind('<Return>'   => $callback);
  $t->bind('<Double-1>' => $callback);
  return $t;
}

# macrolist, menu, UI
# TrEd::List::Macros::update_view
sub update_view {
  my ($grp,$win) = main::grp_win($_[0]);
  return if $grp->{noUpdateMacrolistView};
  my $view = $grp->{sidePanel} && $grp->{sidePanel}->widget('macroListView');
  return unless $view and $view->is_shown();
  my $hl=$view->data;
  create_items($grp,$hl,
		       $grp->{selectedContext},
		       $grp->{macroListViewAnonymous},
		       $grp->{macroListViewCalls},
		       $grp->{macroListViewOrder},
		       $grp->{macroListViewSwap},
		      );
}

# macro, menu, UI
sub create_items {
  my ($grp,$t,$context,$include_anonymous,$see_macro,$order_by,$swap)=@_;
  my $e;
  my $style = $t->{default_style_text};
  $t->delete('all');
  $t->columnWidth(1,$see_macro ? $EMPTY_STR : 0);
  foreach my $entry (sorted_macro_table($grp,$context,$include_anonymous,$order_by)) {
    $e= $t->addchild($EMPTY_STR, -data => $entry->[2]);
    my $col0 = $entry->[1];
    my $col2 = (defined($entry->[0]) ? $entry->[0] : 'ANONYMOUS');
    $col2=~s/^_+//;
    ($col0,$col2)=($col2,$col0) if $swap;
    $t->itemCreate($e, 0, -itemtype=>'text', -text=>$col0, -style=>$style);
    $t->itemCreate($e, 1, -itemtype=>'text', -text=>$entry->[2],-style=>$style) if $see_macro;
    $t->itemCreate($e, 2, -itemtype=>'text', -text=>$col2, -style=>$style);
    $t->header(configure => 0, -text=>$swap ? 'Name' : 'Key');
    $t->header(configure => 2, -text=>$swap ? 'Key'  : 'Name');
  }
}

# macro, UI
sub sorted_macro_table {
  my ($grp,$context,$flags,$order_by) = @_;
  $flags||=0;
  # 1=include-anonymous, 
  # 2=include-TredMacro,
  # 4=include-Default (not yet implemented)

  my $Keys = { %{$TrEd::Macros::keyBindings{$context} ||={} } };
  my $Menus = { %{$TrEd::Macros::menuBindings{$context} ||= {}} };
  if (($flags & 2) and ($context ne 'TredMacro')) {
    my $tmKeys = $TrEd::Macros::keyBindings{TredMacro};
    my ($k,$v);
    while (($k,$v)=each %{ $TrEd::Macros::menuBindings{TredMacro} }) {
      $Menus->{$k.' (TredMacro)'}=$v unless ($v->[1] and exists $Keys->{$v->[1]});
    }
    while (($k,$v)=each %{ $TrEd::Macros::keyBindings{TredMacro} }) {
      $Keys->{$k}||=$v;
    }
  }
  my %macro_to_key = reverse %{ $Keys };
  my %macro_to_menu = map { $Menus->{$_}->[0] => $_ } keys %{ $Menus };

  my @macroTable=
    grep { defined($_->[2]) }
    map {#TODO:
      my ($macro,$key) = @{ $Menus->{$_} };
      $key ||= $EMPTY_STR;
      [ $_, (
      exists($Keys->{$key}) && $Keys->{$key} eq $macro ? 
      $key : 
      $macro_to_key{$macro}),
      $macro ]
    } keys %{ $Menus };
  if ($flags|1) {
    push @macroTable,
      grep { defined($_->[2]) }
      map {
	my $macro = $Keys->{$_};
	exists($macro_to_menu{ $macro }) ? () : [ undef, $_, $macro ];
      } keys %{ $Keys };
  }
  if ($order_by eq 'K') {
    return sort {
      my @a= split '\+',$a->[1];
      my @b= split '\+',$b->[1];
      return $#a <=> $#b if ($#a != $#b);
      for my $i (0..$#a) {
	my ($ak,$bk) = ($a[$i],$b[$i]);
	return length($ak) cmp length($bk) if (length($ak) != length($bk));
	return $ak cmp $bk if ($ak ne $bk);
      }
      return $a cmp $b;
    } @macroTable;
  } elsif ($order_by eq 'P') {
    return sort { $a->[2] cmp $b->[2] } @macroTable;
  } else {
    return TrEd::MinMax::underscore_sort(@macroTable);
  }
}


1;