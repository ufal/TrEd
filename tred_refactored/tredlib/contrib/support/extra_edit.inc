# -*- cperl -*-
# Additional macros and bindings for creating trees from scratch

#ifndef no_extra_edit_key_bindings

#bind new_tree_after Alt+N
#bind new_rbrother to Alt+Right
#bind new_lbrother to Alt+Left
#bind new_son to Alt+Down
#bind new_parent to Alt+Up

#bind trim_subtree Alt+T
#bind delete_node_keep_children to Delete
#bind DeleteSubtree to Ctrl+Delete

#bind cut_to_clipboard to Shift+Delete
#bind copy_to_clipboard to Ctrl+Insert
#bind paste_from_clipboard to Shift+Insert
#bind paste_as_new_tree to Ctrl+Shift+Insert

#bind cut_to_parents_parent to Ctrl+Up
#bind cut_to_parents_rbrother to Ctrl+Right
#bind cut_to_parents_lbrother to Ctrl+Left
#bind cut_to_sibling to Ctrl+Down

#bind ShiftLeft to Ctrl+Shift+Left
#bind ShiftRight to Ctrl+Shift+Right
#bind ShiftSToverSTLeft to Alt+Shift+Left
#bind ShiftSToverSTRight to Alt+Shift+Right

#endif no_extra_edit_key_bindings

#ifndef no_extra_edit_menu_bindings

#insert ShiftSTLeft as menu Move subtree to the left
#insert ShiftSTRight as menu Move subtree to the right
#insert ProjectivizeCurrentSubTree as menu Projectivize subtree
#insert ProjectivizeTree as menu Projectivize tree

#insert new_tree_after as menu New tree
#insert new_rbrother as menu New right brother node
#insert new_lbrother as menu New left brother node
#insert new_son as menu New son node
#insert new_parent as menu New parent node

#insert trim_subtree as menu Trim (remove all but current subtree)
#insert delete_node_keep_children as menu Delete current node (pasting its children on its parent)
#insert DeleteSubtree as menu Delete current subtree

#insert cut_to_clipboard as menu Cut subtree to clipboard
#insert copy_to_clipboard as menu Copy subtree to clipboard
#insert paste_from_clipboard as menu Paste subtree from clipboard
#insert paste_as_new_tree as menu Paste as new tree

#insert cut_to_parents_parent as menu Place node on parent's parent
#insert cut_to_parents_rbrother as menu Place node on parent's right brother
#insert cut_to_parents_lbrother as menu Place node on parent's left brother
#insert cut_to_sibling as menu Place node on its left- or right-sibling (whichever exists)

#insert ShiftLeft as menu Move node to the left
#insert ShiftRight as menu Move node to the right
#insert ShiftSToverSTLeft as menu Swap subtree with subtree to the left
#insert ShiftSToverSTRight as menu Swap subtree with subtree to the right

#endif no_extra_edit_menu_bindings

#include "reordering.inc"

sub new_tree_after {
    return DetermineNodeType( NewTreeAfter() );
}

sub new_rbrother {
    my $save = $this;
    my $new  = NewRBrother();
    if ( !DetermineNodeType($new) ) {
        DeleteLeafNode($new);
        $this = $save;
        return;
    }
    return $new;
}

sub new_lbrother {
    my $save = $this;
    my $new  = NewLBrother();
    if ( !DetermineNodeType($new) ) {
        DeleteLeafNode($new);
        $this = $save;
        return;
    }
    return $new;
}

sub new_son {
    my $save = $this;
    my $new  = NewSon();
    if ( !DetermineNodeType($new) ) {
        DeleteLeafNode($new);
        $this = $save;
        return;
    }
    return $new;
}

sub new_parent {
    return if !$this->parent;
    my $save = $this;
    my $new  = NewParent();
    if ( !DetermineNodeType($new) ) {
        delete_node_keep_children($new);
        $this = $save;
        return;
    }
    return $new;
}

sub cut_to_firstson {
    return if ( !$this || !$this->firstson || !$this->parent );
    my $p = $this->parent;
    my $first_son = $this->firstson;

    if (   !$first_son->test_child_type($this)
        || !$p->test_child_type($first_son)
        || first { !$first_son->test_child_type($_) } $this->children )
    {
        QuestionQuery( 'Cannot move node',
            "Incompatible node types!\n", 'Ok' );
        return;
    }

    CutNode($first_son);
    $this = CutPaste( $this, $first_son );
    $first_son = PasteNode( $first_son, $p );
    foreach ( $this->children ) {
        CutPaste( $_, $first_son );
    }
    return;
}

sub cut_to_parents_parent {
    my $p = $this && $this->parent && $this->parent->parent;
    return if !$p;
    if ( !$p->test_child_type($this) ) {
        QuestionQuery( 'Cannot move node',
            "Incompatible node types!\n", 'Ok' );
        return;
    }

    my $ordering = TredMacro::_node_ord( $this->parent );
    if ( defined $ordering && length $ordering ) {
        return CutPaste( $this, $p );
    }
    else {
        return CutPasteAfter( $this, $this->parent );
    }
}

sub cut_to_parents_rbrother {
    return if (!$this || !$this->parent || !$this->parent->rbrother);
    my $parents_rbrother = $this->parent->rbrother;
    if ( !$parents_rbrother->test_child_type($this) ) {
        QuestionQuery( 'Cannot move node',
            "Incompatible node types!\n", 'Ok' );
        return;
    }
    return CutPaste( $this, $parents_rbrother );
}

sub cut_to_parents_lbrother {
    return if (!$this || !$this->parent || !$this->parent->lbrother);
    my $parents_lbrother = $this->parent->lbrother;
    if ( !$parents_lbrother->test_child_type($this) ) {
        QuestionQuery( 'Cannot move node',
            "Incompatible node types!\n", 'Ok' );
        return;
    }
    return CutPaste( $this, $parents_lbrother );
}

sub cut_to_sibling {
    return if !$this;
    my $sibling = $this->lbrother;
    if ($sibling) {
        if ( $sibling->firstson ) {
            my $ordering = TredMacro::_node_ord( $sibling->firstson );
            if ( defined $ordering and length $ordering ) {
                if ( !$sibling->test_child_type($this) ) {
                    QuestionQuery(
                        'Cannot move node',
                        "Incompatible node types!\n",
                        'Ok'
                    );
                    return;
                }
                CutPaste( $this, $sibling );
            }
            else {
                if ( !$sibling->test_child_type($this) ) {
                    QuestionQuery(
                        'Cannot move node',
                        "Incompatible node types!\n",
                        'Ok'
                    );
                    return;
                }
                $sibling = $sibling->firstson;
                while ($sibling->rbrother) {
                    $sibling = $sibling->rbrother;
                }
                CutPasteAfter( $this, $sibling );
            }
        }
        else {
            if ( !$sibling->test_child_type($this) ) {
                QuestionQuery(
                    'Cannot move node',
                    "Incompatible node types!\n",
                    'Ok'
                );
                return;
            }
            CutPaste( $this, $sibling );
        }
    }
    elsif ( $sibling = $this->rbrother ) {
        if ( $sibling->firstson ) {
            my $ordering = TredMacro::_node_ord( $sibling->firstson );
            if ( defined $ordering && length $ordering ) {
                if ( !$sibling->test_child_type($this) ) {
                    QuestionQuery(
                        'Cannot move node',
                        "Incompatible node types!\n",
                        'Ok'
                    );
                    return;
                }
                CutPaste( $this, $sibling );
            }
            else {
                if ( !$sibling->test_child_type($this) ) {
                    QuestionQuery(
                        'Cannot move node',
                        "Incompatible node types!\n",
                        'Ok'
                    );
                    return;
                }
                $sibling = $sibling->firstson;
                while ($sibling->lbrother) {
                    $sibling = $sibling->lbrother;
                }
                CutPasteBefore( $this, $sibling );
            }
        }
        else {
            if ( !$sibling->test_child_type($this) ) {
                QuestionQuery(
                    'Cannot move node',
                    "Incompatible node types!\n",
                    'Ok'
                );
                return;
            }
            CutPaste( $this, $sibling );
        }
    }
    return;
}

sub trim_subtree {
    return if ( !$this || !$root || !$this != $root );
    my $node = $this;
    CutNode($node);
    $grp->{FSFile}->set_tree( $node, $grp->{treeNo} );
    $root->destroy;
    $this = $node;
    $root = $node;
    return;
}

sub copy_to_clipboard {
    return if (!$this);
    $TredMacro::nodeClipboard = CloneSubtree($this);
    return;
}

sub cut_to_clipboard {
    return if ( !$this || !$this->parent );
    $TredMacro::nodeClipboard = $this;
    $this = $this->rbrother ? $this->rbrother : $this->parent;
    CutNode($TredMacro::nodeClipboard);
    if ( _node_ord($TredMacro::nodeClipboard) ) {
        my $nodesref = GetNodes();
        SortByOrd($nodesref);
        NormalizeOrds($nodesref);
    }
    return;
}

sub paste_from_clipboard {
    return if ( !$this || !$TredMacro::nodeClipboard );
    if ( !$this->test_child_type($TredMacro::nodeClipboard) ) {
        QuestionQuery(
            'Cannot paste node',
            "The type of the clipboard node is not compatible\n"
                . 'with the current node!',
            'Ok'
        );
        return;
    }
    if ( _node_ord($this) ) {
        my $clipnodes = GetNodes($TredMacro::nodeClipboard);
        SortByOrd($clipnodes);
        NormalizeOrds($clipnodes);
        my $nodes = GetNodes($root);
        SortByOrd($nodes);
        NormalizeOrds($nodes);
        my $ord   = FS()->order;
        my $shift = $this->{$ord};

        foreach my $node (@{$clipnodes}) {
            $node->{$ord} += $shift;
        }
        foreach my $node (@{$nodes}) {
            if ($node->{$ord} > $shift) {
                $node->{$ord} += $#{$clipnodes} + 1;
            }
        }
    }
    PasteNode( $TredMacro::nodeClipboard, $this );
    $this = $TredMacro::nodeClipboard;
    $TredMacro::nodeClipboard = undef;
    return;
}

sub paste_as_new_tree {
    return if ( !$grp->{FSFile} || !$TredMacro::nodeClipboard );

    if ($this) {
        my $clipnodes = GetNodes($TredMacro::nodeClipboard);
        SortByOrd($clipnodes);
        NormalizeOrds($clipnodes);
    }
    my $pos = $grp->{FSFile}->lastTreeNo() + 1;
    $grp->{FSFile}->insert_tree( $TredMacro::nodeClipboard, $pos );
    GotoTree( $pos + 1 );
    $TredMacro::nodeClipboard = undef;
    return;
}

sub delete_node_keep_children {
    if (!ref $_[0]) {
        shift;
    }
    my $node = shift() || $this;
    my $parent = $node->parent;
    return if !$parent;
    if ( first { !$parent->test_child_type($_) } $node->children ) {
        QuestionQuery(
            'Cannot delete node',
            "The node cannot be deleted: some of its child nodes\n"
                . 'has incompatible type with the parent node!',
            'Ok'
        );
        return;
    }

    my $ordering = TredMacro::_node_ord($node);
    if ( defined $ordering && length $ordering ) {
        for my $child ( $node->children ) {
            CutPaste( $child, $parent );
        }
    }
    else {
        for my $child ( $node->children ) {
            CutPasteBefore( $child, $node );
        }
    }
    DeleteLeafNode($node);
    if ( $this == $node ) {
        $this = $parent;
    }
    return;
}
