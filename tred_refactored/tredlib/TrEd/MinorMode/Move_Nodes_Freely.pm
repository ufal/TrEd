# -*- cperl -*-
package TrEd::MinorMode::Move_Nodes_Freely;

use strict;
use warnings;

require TrEd::MacroAPI::Default; # loads TredMacro
TredMacro->import();

require TrEd::Macros;
require TrEd::MinorModes;

=head1 move_nodes_freely.inc

This file provides generic support for manual repositioning of nodes
on the canvas.

=head2 USAGE

Add this line to your macro context:

  #include <contrib/support/move_nodes_freely.inc>

And these to your stylesheet:

style:<?
  my ($x,$y)=($this->{'.xadj'}||0,$this->{'.yadj'}||0);
  qq(#{Node-xadj:$x}#{Node-yadj:$y})
 ?>

Then you can drag nodes over the canvas. When releasing the node with
Shift pressed, the node (and its labels and edge-ends) move to the
given position; if Control is pressed, then the complete subtree is
moved in this way.

=head2 CUSTOMIZING

You may modify these default bindings by setting
e.g.:

  $move_nodes_freely{subtree}='Alt'; # default is Control
  $move_nodes_freely{node}='Meta'; # default is Shift

=head2 WRAPPING

If you want to wrap this code into a more complex hook, you can do it
by using a class:

  package MyContext::MoveSupport;
  import TredMacro;
  #include <contrib/support/move_nodes_freely.inc>

  package MyContext;
  import TredMacro;
  # ...
  sub node_release_hook {
    my (@args)=@_;
    if (MyContext::MoveSupport::node_release_hook(@args) eq 'subtree') {
       # the hook moved a subtree
    } else (MyContext::MoveSupport::node_release_hook(@args) eq 'node') {
       # the hook moved a node
    } else {
       # the hook moved nothing
    }
  }

=head2 A FINAL NOTE

This implementation adds the attributes .xadj and .yadj to the
moved nodes. These may be preserved by some I/O backends,
e.g. Storable.

=cut

my %move_nodes_freely = (
    node    => 'Shift',
    subtree => 'Control',
);

sub node_release_hook {
    my ( $node, $parent, $mod, $e ) = @_;
    my @apply_to;
    my $what;
    if ( $mod eq $move_nodes_freely{node} ) {
        $what     = 'node';
        @apply_to = ($node);
    }
    elsif ( $mod eq $move_nodes_freely{subtree} ) {
        $what = 'subtree';
        @apply_to = ( $node, $node->descendants );
    }
    else {
        return;
    }
    my ( $x, $y ) = ( $e->x, $e->y );
    my $grp = TrEd::Macros::get_macro_variable('grp');

    # grp should be imported from TredMacro...
    my $tv     = $grp->treeView;
    my $canvas = $tv->realcanvas;
    $x = $canvas->canvasx($x);
    $y = $canvas->canvasy($y);
    my $scale_factor = $tv->scale_factor();
    my $xdelta
        = ( $x - $tv->get_node_pinfo( $node, "XPOS" ) ) / $scale_factor;
    my $ydelta
        = ( $y - $tv->get_node_pinfo( $node, "YPOS" ) ) / $scale_factor;

    for my $n (@apply_to) {
        $n->{'.xadj'} += $xdelta;
        $n->{'.yadj'} += $ydelta;
    }
    if (@apply_to) {
        Redraw_FSFile_Tree();
        ChangingFile(1);
    }
    return $what;
}

sub init_minor_mode {
    my ($grp) = @_;
    $move_nodes_freely{subtree} = 'Alt';

    return if !TrEd::Macros::is_defined('TRED');
    TrEd::MinorModes::declare_minor_mode( $grp, 'Move_Nodes_Freely' => {
            abbrev     => 'move',
            post_hooks => {
                node_release_hook => \&node_release_hook,
                node_style_hook   => sub {
                    my ( $node, $styles ) = @_;
                    AddStyle( $styles, 'Node',
                        -xadj => $node->{'.xadj'} || 0 );
                    AddStyle( $styles, 'Node',
                        -yadj => $node->{'.yadj'} || 0 );
                },
            },
        } );

#    DeclareMinorMode(
#        'Move_Nodes_Freely' => {
#            abbrev     => 'move',
#            post_hooks => {
#                node_release_hook => \&node_release_hook,
#                node_style_hook   => sub {
#                    my ( $node, $styles ) = @_;
#                    AddStyle( $styles, 'Node',
#                        -xadj => $node->{'.xadj'} || 0 );
#                    AddStyle( $styles, 'Node',
#                        -yadj => $node->{'.yadj'} || 0 );
#                },
#            },
#        }
#    );

}

1;
