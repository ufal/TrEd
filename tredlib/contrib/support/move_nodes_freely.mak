
#ifndef Move_Nodes_Freely
#define Move_Nodes_Freely

# -*- cperl -*-

package Move_Nodes_Freely;

BEGIN {
  import TredMacro;
}

#include "move_nodes_freely.inc"

$move_nodes_freely{subtree} = 'Alt';
DeclareMinorContext 'Move_Nodes_Freely' => {
  post_hooks => {
    node_release_hook => \&node_release_hook,
    node_style_hook => sub {
      my ($node,$styles)=@_;
      AddStyle($styles,'Node',-xadj => $node->{'.xadj'}||0);
      AddStyle($styles,'Node',-yadj => $node->{'.yadj'}||0);
    },
  },
};

1;

#endif Move_Nodes_Freely
