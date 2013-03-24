## This was macro file for Tred (tred.def)  -*-cperl-*-
## author: Petr Pajas
## $Id: tred.def 4547 2011-01-06 23:35:45Z fabip4am $

package TredMacro;

use strict;
use warnings;

use Exporter;
use Treex::PML;
use UNIVERSAL::DOES;
use Scalar::Util qw(blessed);
use TrEd::MinMax qw(first max maxstr min minstr reduce sum);

use base qw(Exporter);
use Carp;
use vars qw(@FORCE_EXPORT @EXPORT);
require Encode;

# should they be exported?
#        can
#        isa
BEGIN {
    @FORCE_EXPORT
        = qw($libDir $grp $root $this $_NoSuchTree $Redraw $stderr $stdout
        $forceFileSaved $FileChanged $FileNotSaved $NodeClipboard @AUTO_CONTEXT_GUESSING);
    @EXPORT = qw{
        AbsolutizeFileName
        AddBackend
        AddNewFileList
        AddStyle
        AddToAlt
        AddToList
        AddToListUniq
        AddToSeq
        Alt
        AltV
        AppendFSHeader
        AttachTooltip
        Attributes
        Backends
        Bind
        CallerDir
        CallerPath
        can
        CenterOtherWinTo
        ChangingFile
        CloneSubtree
        CloseFile
        CloseFileInWindow
        CloseGUI
        CloseWindow
        configure_node_menu_items
        context_guessing
        CopyNode
        CopyValues
        CopyValues_nochange
        critical_node_menu_items
        _croak
        CurrentContext
        CurrentContextForWindow
        CurrentFile
        CurrentFileNo
        CurrentNodeInOtherWindow
        CurrentTreeNumber
        CurrentWindow
        CustomColor
        Cut
        CutNode
        CutPaste
        CutPasteAfter
        CutPasteBefore
        CutToClipboard
        DeclareMinorMode
        DefaultInputEncoding
        DeleteLeafNode
        DeleteStylesheet
        DeleteSubtree
        DeleteThisNode
        DestroyTree
        DestroyUserToolbar
        DetermineNodeType
        DirPart
        DisableMinorMode
        disable_node_menu_items
        DisableUserToolbar
        EditAttribute
        EditBoxQuery
        EnableMinorMode
        enable_node_menu_items
        EnableUserToolbar
        ErrorMessage
        exit_hook
        FileAppData
        FileMetaData
        FileName
        FilePart
        FileUserData
        Find
        FindMacroDir
        FindNext
        FindNext_nochange
        Find_nochange
        FindPrev
        FindPrevious_nochange
        FirstTree
        ForgetRedo
        FPosition
        FS
        GetBalloonPattern
        GetCurrentFileList
        GetCurrentStylesheet
        GetDisplayAttrs
        GetDisplayedNodes
        GetFileList
        GetFileSaveStatus
        GetMinorModeData
        GetNodeIndex
        GetNodes
        GetNodesExceptSubtree
        GetOpenFiles
        GetOrd
        GetPatternsByPrefix
        GetSecondaryFiles
        GetSpecialPattern
        GetStyles
        GetStylesheetPatterns
        GetTrees
        GetUserToolbar
        GetVisibleNodes
        GotoFileAsk
        GotoFileNo
        GotoNextNodeLin
        GotoPrevNodeLin
        GotoTree
        GotoTreeAsk
        guess_context_hook
        GUI
        HiddenVisible
        Hide
        HideUserToolbar
        import
        import_only
        InfoMessage
        init_hook
        initialize_bindings_hook
        init_tredmacro_bindings
        InVerticalMode
        isa
        IsAlt
        IsHidden
        IsList
        IsMinorModeEnabled
        IsSeq
        LastFileNo
        LastTree
        List
        ListEnabledMinorModes
        ListIntersect
        ListQuery
        ListRegroupElements
        ListSubtract
        ListUnion
        ListV
        LocateNode
        MacroCallback
        MoveNode
        MoveSubtree
        NewLBrother
        NewParent
        NewRBrother
        NewSon
        NewTree
        NewTreeAfter
        NewUserToolbar
        NextFile
        NextNode
        NextNodeLinear
        NextTree
        NextTree_nochange
        NextVisibleNode
        node_menu_item_cget
        noop
        NormalizeOrds
        NPosition
        Open
        open_file_hook
        OpenSecondaryFiles
        OverrideBuiltinBinding
        ParseNodeAddress
        PasteFromClipboard
        PasteNode
        PasteNodeAfter
        PasteNodeBefore
        PasteValues
        PerlEval
        PerlSearch
        PerlSearchNext
        PlainDeleteNode
        PlainDeleteSubtree
        PlainNewSon
        PrevFile
        PrevNode
        PrevNodeLinear
        PrevTree
        PrevTree_nochange
        PrevVisibleNode
        Print
        PrintDialog
        priority_context_guessing
        QueryString
        QuestionQuery
        QuickPML
        quit
        Redo
        Redraw
        Redraw_All
        RedrawAndUpdateThis
        Redraw_FSFile
        Redraw_FSFile_Tree
        RedrawStatusLine
        register_exit_hook
        register_init_hook
        register_initialize_bindings_hook
        register_open_file_hook
        register_reload_macros_hook
        register_start_hook
        ReloadCurrentFile
        reload_macros_hook
        ReloadStylesheet
        ReloadStylesheets
        RemoveBackend
        RemoveFileList
        RemoveTree
        RemoveUserToolbar
        RepasteNode
        ResumeFile
        RunCallback
        Save
        SaveAndNextFile
        SaveAndPrevFile
        SaveAs
        SaveStylesheet
        SaveStylesheets
        SaveUndo
        SeqV
        SetBalloonPattern
        SetCurrentFileList
        SetCurrentFileListInWindow
        SetCurrentNodeInOtherWindow
        SetCurrentStylesheet
        SetCurrentWindow
        SetDefaultInputEncoding
        SetDisplayAttrs
        SetFileSaveStatus
        SetMinorModeData
        SetStylesheetPatterns
        SetupXPath
        ShiftNodeLeft
        ShiftNodeLeftSkipHidden
        ShiftNodeRight
        ShiftNodeRightSkipHidden
        ShowUserToolbar
        SlurpURI
        SortByOrd
        SplitWindowHorizontally
        SplitWindowVertically
        StandardTredFont
        StandardTredValueLineFont
        start_hook
        stderr
        stdout
        StylesheetExists
        STYLESHEET_FROM_FILE
        Stylesheets
        SubstituteFSHeader
        SwitchContext
        SwitchContextForWindow
        ThisAddress
        ThisAddressNTRED
        TieFirstTree
        TieGotoTree
        TieGotoTreeAsk
        TieLastTree
        TieNextTree
        TieNextTree_nochange
        TiePrevTree
        TiePrevTree_nochange
        tmpFileName
        ToggleHiding
        ToplevelFrame
        TrEdFileLists
        TrEdWindows
        UnbindBuiltin
        UndeclareAttributes
        Undo
        uniq
        unregister_exit_hook
        unregister_init_hook
        unregister_initialize_bindings_hook
        unregister_open_file_hook
        unregister_reload_macros_hook
        unregister_start_hook
        UserConf
        UserToolbarVisible
        writeln
        ntred_query_box_make_filelist
        ntred_query_box_do_query
        ntred_query_box
        ntred_query
        Position
    };

    #new
    #message
    #throw
    #quit
    #_import
    *FileChanged = \$TredMacro::FileNotSaved;    # alias
    import Treex::PML qw(ImportBackends);
    import Treex::PML
        qw(&Index &CloneValue &FindInResources &FindDirInResources &ResolvePath);

    #  import main;

    # these includes are only for tred with GUI
    if ( exists &Tk::MainLoop ) {
        require TrEd::Binding::Default;
        require TrEd::ManageFilelists;
        require TrEd::Filelist::Navigation;
        require TrEd::Toolbar::User::Manager;

    }

}

use vars @FORCE_EXPORT;

# new ones
require TrEd::Window::TreeBasics;
require TrEd::Error::Message;

require TrEd::File;
require TrEd::Utils;
require TrEd::Config;
require TrEd::Convert;
require TrEd::MinorModes;
require TrEd::Stylesheet;

# can't 'use', circular ref
require TrEd::Macros;
require TrEd::MacroAPI::Extended;         # instead of tred.mac
require TrEd::NtredMak;    # instead of contrib/ntred/contrib.mac and ntred.mak,

# The following is a workaround for a nasty bug of Class::Std in case somebody wants to use it
sub isa {
    return &UNIVERSAL::isa;
}

sub can {
    return &UNIVERSAL::can;
}

sub _croak {
    my ( $pkg, $file, $line ) = caller(1);
    die join( '', @_ ) . ' at ' . $file . ' line ' . $line . "\n";
}

=pod

=head1 TredMacro

TredMacro (F<tred.def>) - implements the public API for TrEd/bTred macros

=head2 Global variables

=over 4

=item C<$this>

Current node (i.e. the active node in TrEd and the node in turn if
C<-N> or C<-H> flag was used in bTrEd). Assigning a different node
from the current tree to this variable results in changing the active
node in TrEd and continuing processing at that node in bTrEd.

=item C<$root>

Root of the current tree. If possible, avoid changing this variable in
a macro, so that called macros may rely on its value too.

=item C<$FileChanged> (alias C<$FileNotSaved> - still valid but obsolete)

See also C<ChangingFile()>.

If this variable is set to 1, TrEd/bTrEd considers the current file to
be modified and in case of bTrEd makes the program to save it before
it is closed (in case of TrEd, user is prompted before the file is
closed). If the macro does not change this variable, bTrEd does not
change the file status, while TrEd still assumes that the file B<was>
modified. In other words, set this variable to 1 in bTrEd if you want
the file to be saved at last, and set this variable to 0 in TrEd if
you are sure you did not make any change to the file that would be
worth saving it. As there is a danger that calling one macro from
another may result in a mess in the value of C<$FileChanged> it is
adviced to use the default macro C<ChangingFile()> which tries to set
the file status only if really intended (see below).

=item C<$Redraw>

This variable makes sense only in TrEd.  You may set it to one of
C<file>, C<tree>, C<win>, C<all>, C<tie> to alter the mechanism of redrawing the
screen. The default value is C<file> (redraw all windows displaying
current file), while C<tree> means redraw all windows displaying
current tree, C<win> means redraw only current window and C<tie> means
redraw all if windows are tied or (if not) redraw only current window.
To disable redrawing set this variable to C<none>.

=item C<$forceFileSaved>

In TrEd, you may wish to set this variable to 0 if you wish to change
the status of the file to C<saved> (e.g. after saving the file from
your macro).

=item C<$libDir>

This variable contains a path to TrEd library directory.

=back

=cut

## =head2 FUNCTION REFERENCE

###########################################################

=head2 Navigation

Methods of L<Treex::PML::Node|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Node.pm>
objects should be used for basic navigation within
trees. Here are described means to navigate from one tree to another
and a few extra macros for specific navigation in trees.

=over 4

=item C<GotoTree(n)>

Display the n'th tree in the current file.
The number of the first tree for this function is 1.

=cut

sub GotoTree {
    #  $FileNotSaved=0 if ($FileNotSaved eq '?');
    my $to = shift() - 1;
    my $result = TrEd::Window::TreeBasics::go_to_tree( $grp, $to );
    $_NoSuchTree = ( $to != $result );
    $root        = $grp->{root};
    $this        = $root;
    return $result;
}

=item C<TieGotoTree(n)>

Go to n'th tree in all tied windows.
The number of the first tree for this function is 1.

=cut

sub TieGotoTree {
    #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
    my $to = shift() - 1;
    my $result = main::tieGotoTree( $grp, $to );
    $root   = $grp->{root};
    $this   = $root;
    $Redraw = 'tie';
    return $result;
}

=item C<TieNextTree()>

Display the next tree in all tied windows.

=cut

sub TieNextTree {
    #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
    my $result = main::tieNextTree($grp);
    $root   = $grp->{root};
    $this   = $root;
    $Redraw = 'tie';
    return $result;
}

=item C<TiePrevTree()>

Display the previous tree in all tied windows.

=cut

sub TiePrevTree {
    #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
    my $result = main::tiePrevTree($grp);
    $root   = $grp->{root};
    $this   = $root;
    $Redraw = 'tie';
    return $result;
}

=item C<NextTree()>

Display the next tree in the current file.

=cut

sub NextTree {
    #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
    my $result = TrEd::Window::TreeBasics::next_tree($grp);
    $root        = $grp->{root};
    $this        = $root;
    $_NoSuchTree = !$result;       # for compatibility with Graph2Tred
    return $result;
}

=item C<PrevTree()>

Display the previous tree in the current file.

=cut

sub PrevTree {
    #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
    my $result = TrEd::Window::TreeBasics::prev_tree($grp);
    $root        = $grp->{root};
    $this        = $root;
    $_NoSuchTree = !$result;       # for compatibility with Graph2Tred
    return $result;
}

=item C<GetTrees()>

Return a list of trees in current L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>. Equivallent to
C<<< CurrentFile()->trees >>>.

=cut

sub GetTrees {
    my ($package, $filename, $line) = caller;
    #print "gettin trees: called from $package:$line ($filename)\n";
    my $fsfile = CurrentFile();
    if ($fsfile) {
        return $fsfile->trees;
    }
    else {
        croak(
            "Cannot get trees: no Treex::PML::Document is currently open\n");
    }
}

=item C<GetSecondaryFiles($fsfile?)>

Return a list of secondary L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> objects for the given (or current)
file.  A secondary file is a file required by a file to be loaded
along with it; this is typical for files containing some form of a
stand-off annotation where one tree is built upon another. Note
however, that this does not include so called knitting - an operation
where the stand-off annotation is handled by a IO backend and the
resulting knitted file appears to btred as a single unit.
Only those secondary files that are already open are returned.

=cut

sub GetSecondaryFiles {
    my ($fsfile) = @_;
    $fsfile ||= CurrentFile();
    return
        exists(&TrEd::File::get_secondary_files)
        ? TrEd::File::get_secondary_files($fsfile)
        : ();
}

=item C<NextNode(node,top?)>

Return the first displayed node following the given node in the
subtree of top. This function behaves in the same manner as the
node->following(top) method, except it works only on the nodes which
are actually visible according to the state of the View->Show Hidden
Nodes menu item.

=cut

sub NextNode {
    my ( $node, $top ) = @_;
    return $node ? main::NextDisplayed( $grp, $node, $top ) : undef;
}

=item C<PrevNode(node,top?)>

Return the first displayed node preceding the given node in the
subtree of top. This function behaves in the same manner as the
node->previous(top) method, except it works only on the nodes which
are actually visible according to the state of the View->Show Hidden
Nodes menu item.

=cut

sub PrevNode {
    my ( $node, $top ) = @_;
    return $node ? main::PrevDisplayed( $grp, $node, $top ) : undef;
}

=item C<NextVisibleNode(node,top?)>

Return the first visible node following the given node in the subtree
of top. This function behaves in the same manner as the
C<$node-E<gt>following($top)> method, except that nodes of hidden subtrees
are skipped.

=cut

sub NextVisibleNode {
    my ( $node, $top ) = @_;
    $node = $node->following($top);
    my $fs = FS();
    while ($node) {
        return $node unless ( $fs->isHidden($node) );
        $node = $node->following_right_or_up($top);
    }
    return 0;
}

=item C<PrevVisibleNode(node,top?)>

Return the first visible node preceding the given node in the subtree
of top. This function behaves in the same manner as the
C<$node-E<gt>previous($top)> method, except that nodes of hidden subtrees
are skipped.

=cut

sub PrevVisibleNode {
    my ( $node, $top ) = @_;
    $node = $node->previous($top);
    my $fs = FS();
    while ($node) {
        return $node unless ( $fs->isHidden($node) );
        $node = $node->previous($top);
    }
    return 0;
}

=item C<IsHidden(node)>

Return true if the given node is member of a hidden subtree. This
macro is only an abbreviation for
C<< FS()->isHidden(node) >>

=cut

sub IsHidden {
    my ($node) = @_;
    return FS()->isHidden($node);
}

=item C<Hide(node)>

Hide a given node.

=cut

sub Hide {
    my ($node) = @_;
    my $hide = FS()->hide();
    if ( $node and $hide ne "" ) {
        $node->{$hide} = 'hide';
        return 1;
    }
    return 0;
}

=item C<GetNodes(top?)>

Get a list of all nodes in the current tree or (if top is given) in
the subtree of top (the root of the tree is icluded as well). The list
returned is ordered in the depth-first ordering.
(This function automatically returns array reference in scalar context.)

=cut

sub GetNodes {
    my $top = defined( $_[0] ) ? $_[0] : $root;
    my $node = $top;
    my @n;
    while ($node) {
        push @n, $node;
        $node = $node->following($top);
    }
    return wantarray ? @n : \@n;
}

=item C<GetVisibleNodes(top?)>

Return the list of all visible nodes in the subtree of the given top
node (or the whole current tree if no top is given). The list returned
is ordered in the depth-first ordering and all members of hidden
subtrees are skipped.

=cut

sub GetVisibleNodes {
    my $top = defined( $_[0] ) ? $_[0] : $root;
    my $node = $top;
    my @n;
    while ($node) {
        push @n, $node;
        $node = $node->following_visible( FS(), $top );
    }
    return @n;
}

=item C<GetDisplayedNodes($win?)>

Return the list of all nodes actually currently displayed in the
current window in TrEd (which nodes are actually displayed can be
e.g. specified with get_nodelist_hook).

=cut

sub GetDisplayedNodes {
    my $win = ref( $_[0] ) ? $_[0] : $grp;
    if ( ref $win->{Nodes} ) {
        return @{ $win->{Nodes} };
    }
    return;
}

=item C<PrevNodeLinear(node,attribute,top?)>

Returns nearest node in the tree preceding the given node in linear
ordering provided by the given attribute. If top node is present, only
a subtree of top is examined.

=cut

sub PrevNodeLinear {
    my ( $node, $attr, $top ) = @_;

    return unless $node;

    my $v = $node->{$attr};
    my $best;
    my $best_v;

    my $nv;
    $node = $top || $node->root;    # reusing variable $node
    while ($node) {
        $nv = $node->{$attr};
        if ( $nv < $v
            and ( !$best or $nv > $best_v ) )
        {
            $best_v = $nv;
            $best   = $node;
        }
        $node = $node->following($top);
    }
    return $best;
}

=item C<NextNodeLinear(node,attribute,top?)>

Returns nearest node in the tree following the given node in linear
ordering provided by the given attribute. If top node is present, only
a subtree of top is examined.

=cut

sub NextNodeLinear {
    my ( $node, $attr, $top ) = @_;

    return unless $node;

    my $v = $node->{$attr};
    my $best;
    my $best_v;

    my $nv;
    $node = $top || $node->root;    # reusing the variable
    while ($node) {
        $nv = $node->{$attr};
        if ( $nv > $v
            and ( !$best or $nv < $best_v ) )
        {
            $best_v = $nv;
            $best   = $node;
        }
        $node = $node->following($top);
    }
    return $best;
}

=item C<CurrentTreeNumber( $win? )>

Return current tree number.  Note that the number of the first tree if
file reported by this function is 0, so you have to add 1 before
passing the number to functions like GotoTree.  If used in TrEd,
optional argument win can be used to specify TrEd window (defaults to
the current window).

=cut

sub CurrentTreeNumber {
    shift if @_ and !ref( $_[0] );
    my $win = $_[0] || $grp;
    return $win->{treeNo};
}

=item C<GetNodeIndex()>

Return given node's position in the deep-first tree ordering.

=cut

sub GetNodeIndex {
    my $node = ref( $_[0] ) ? $_[0] : $this;
    my $i = -1;
    while ($node) {
        $node = $node->previous();
        $i++;
    }
    return $i;
}

=item C<LocateNode(node?,fsfile?)>

Return current filename, index of a tree (starting from 1) in the file
to which the node belongs (0 if not found) and node's position in the tree
in the deep-first tree ordering.

If C<node> is not given, C<$this> is assumed. Should the node be from a
different file than the current one, the second argument must specify
the corresponding L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object.

=cut

sub LocateNode {
    my $node
        = ref( $_[0] ) ? $_[0]
        : @_           ? confess("Cannot get position of an undefined node")
        :                $this;
    my $fsfile = ref( $_[1] ) ? $_[1] : CurrentFile();
    return unless ref $node;
    my $tree = $node->root;
    if ( $fsfile == CurrentFile() and $tree == $root ) {
        return ( FileName(), CurrentTreeNumber() + 1, GetNodeIndex($node) );
    }
    else {
        my $i = 1;
        foreach my $t ( $fsfile->trees ) {
            if ( $t == $tree ) {
                return ( $fsfile->filename, $i, GetNodeIndex($node) );
            }
            $i++;
        }
        my $type = $node->type;
        my ($id_attr) = $type && $type->find_members_by_role('#ID');
        return ( $fsfile->filename, 0, GetNodeIndex($node),
            $id_attr && $node->{ $id_attr->get_name } );
    }
}

=item C<ThisAddress(node?,fsfile?)>

Return a given node's address string in a form of
filename#tree_no.index (tree_no starts from 1 to reflect TrEd's UI
convention).  If the correct tree number could not be determined (the
node does not belong to any top-level tree in the file) and the node
has an ID, the address is returned in the form filename#ID.

If C<node> is not given, C<$this> is assumed. Should the node be from a
different file than the current one, the second argument must specify
the corresponding L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object.

=cut

sub ThisAddress {
    my ( $f, $i, $n, $id ) = &LocateNode;
    if ( $i == 0 and $id ) {
        return $f . '#' . $id;
    }
    else {
        return $f . '##' . $i . '.' . $n;
    }
}

=item C<ThisAddressNTRED(node?,fsfile?)>

Return a given node's address string in a form of
ntred://filename@tree_no#1.index (tree_no starts from 1 to reflect
TrEd's UI convention). If the correct tree number could not be
determined (the node does not belong to any top-level tree in the
file) and the node has an ID, the address is returned in the form
ntred://filename#ID.

The returned address may be opened in TrEd to examine the tree in
memory of a remote btred server.

If C<node> is not given, C<$this> is assumed. Should the node be from a
different file than the current one, the second argument must specify
the corresponding L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object.

=cut

sub ThisAddressNTRED {
    my ( $f, $i, $n, $id ) = &LocateNode;
    if ( $i == 0 and $id ) {
        return 'ntred://' . $f . '#' . $id;
    }
    else {
        return 'ntred://' . $f . '@' . $i . '##1.' . $n;
    }
}

=item C<FPosition(node?,fsfile?)>

Prints the result of C<ThisAddress> on stdout.

=cut

sub FPosition { print ThisAddress(@_), "\n"; }

=item C<NPosition(node?,fsfile?)>

Prints the result of C<ThisAddressNTRED> on stdout.

=cut

sub NPosition { print ThisAddressNTRED(@_), "\n"; }

=item C<ParseNodeAddress(address)>

Split given address into a filename/URL and a suffix and return these
as a two element list.

=cut

sub ParseNodeAddress {&main::parse_file_suffix}

=back

=cut

###########################################################

=head2 Tree editing API

=over 4

=item C<CutPaste(node,new-parent)>

Cut given node (including its subtree) and paste it to a new
parent. This macro is safer than PasteNode since it checks that
new-parent is not a descendant of node or node itself. If the check
fails, the macro dies with an error before any change is made.

Note: this macro does not verify node types. Use
C<$parent-E<gt>test_child_type($node)> to be sure that type declarations permit
the node as a child node of the new parent.

=cut

sub Cut {
    my ($node) = @_;
    return $node->cut();
}

sub CutPaste {
    my ( $cutted, $target ) = @_;
    my $p = $target;
    while ($p) {
        if ( $p == $cutted ) {
            _croak( "Cannot paste node to its descendant or self in "
                    . ThisAddress($cutted) );
        }
        $p = $p->parent;
    }
    PasteNode( $cutted, $target );
}

=item C<CutPasteBefore(node,ref_node)>

Cut given node (including its subtree) nd paste it on ref_node's
parent node just before ref_node. This macro is safer than
PasteNodeBefore since it checks that new-parent is not a descendant of
node or node itself. This macro dies on error before any change is
made.

Note: this macro does not verify node types. Use
C<$parent-E<gt>test_child_type($node)> to be sure that type declarations permit
the node as a child node of the new parent.

=cut

sub CutPasteBefore {
    my ( $cutted, $ref_node ) = @_;
    my $p = $ref_node->parent;
    while ($p) {
        if ( $p == $cutted ) {
            _croak( "Cannot paste node to its descendant or self at "
                    . ThisAddress($cutted) );
        }
        $p = $p->parent;
    }
    PasteNodeBefore( $cutted, $ref_node );
}

=item C<CutPasteAfter(node,ref_node)>

Cut given node (including its subtree) and paste it on ref_node's parent node just after
ref_node. This macro is safer than PasteNodeBefore since it checks
that new-parent is not a descendant of node or node itself. This macro
dies on error before any change is made.

Note: this macro does not verify node types. Use
C<$parent-E<gt>test_child_type($node)> to be sure that type declarations permit
the node as a child node of the new parent.

=cut

sub CutPasteAfter {
    my ( $cutted, $ref_node ) = @_;
    _croak( "CutPasteAfter: ref-node not given at " . ThisAddress($cutted) )
        unless $ref_node;
    my $p = $ref_node->parent;
    while ($p) {
        if ( $p == $cutted ) {
            _croak( "Cannot paste node to its descendant or self at "
                    . ThisAddress($cutted) );
        }
        $p = $p->parent;
    }
    PasteNodeAfter( $cutted, $ref_node );
}

=item C<PasteNode(node,new-parent)>

Paste the subtree of the node under the new-parent.  The root of the
subtree is placed among other children of new-parent with respect to
the numbering attribute.

Note: this macro does not verify node types. Use
C<$parent-E<gt>test_child_type($node)> to be sure that type declarations permit
the node as a child node of the new parent.

=cut

sub PasteNode {
    my ( $node, $p ) = @_;
    my $ord = _node_ord($node);
    $node->cut()->paste_on( $p, $ord );
    return $node;
}

=item C<PasteNodeBefore(node,ref_node)>

Cut given node (including its subtree) and paste it on ref_node's
parent node just before ref_node.

Note: this macro does not verify node types. Use
C<$parent-E<gt>test_child_type($node)> to be sure that type declarations permit
the node as a child node of the new parent.

=cut

sub PasteNodeBefore {
    my ( $node, $ref_node ) = @_;
    $node->cut()->paste_before($ref_node);
}

=item C<PasteNodeAfter(node,ref_node)>

Cut given node (including its subtree) and paste it on ref_node's
parent node just after ref_node.

Note: this macro does not verify node types. Use
C<$parent-E<gt>test_child_type($node)> to be sure that type declarations permit
the node as a child node of the new parent.

=cut

sub PasteNodeAfter {
    my ( $node, $ref_node ) = @_;
    $node->cut()->paste_after($ref_node);
}

=item C<CloneSubtree(node)>

Return an identical copy (except that only declared attributes are
preserved) of the given subtree.

=cut

sub CloneSubtree {
    my ($node) = @_;
    return FS()->clone_subtree($node);
}

=item C<CopyNode(node)>

Return an identical copy (except that only declared attributes are
preserved) of the given node. The input node must belong to the
current file.

=cut

sub CopyNode {
    my ($node) = @_;
    return FS()->clone_node($node);
}

=item C<CutNode(node)>

Cut the node's subtree off the tree and return it. By cuttin a subtree
we mean disconnecting it from the rest of the tree. Use PasteNode to
attach it to some node again.

=cut

sub CutNode {
    my $node   = shift;
    my $parent = $node->parent;
    my $result = $node->cut();
    $this = $parent if ( $result and $this == $node );
    return $result;
}

=item C<NewTree()>

Create a new tree before the current tree. The new tree consists of
exactly one node. This node is activated and a reference to its L<Treex::PML::Node|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Node.pm>
object is returned.

=cut

sub NewTree {
    TrEd::Window::TreeBasics::new_tree($grp);
    $root = $grp->{root};
    $this = $root;
    return $root;
}

=item C<NewTreeAfter()>

Create a new tree after the current tree. The new tree consists of
exactly one node. This node is activated and a reference to its L<Treex::PML::Node|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Node.pm>
object is returned.

=cut

sub NewTreeAfter {
    TrEd::Window::TreeBasics::new_tree_after($grp);
    $root = $grp->{root};
    $this = $root;
    return $root;
}

#
# Try heuristically identify the ordering attribute
#

sub _node_ord {
    my ($node) = @_;
    my $type = $node ? $node->type : undef;
    if ($type) {
        my $ord = $node->get_ordering_member_name;
        return $ord if defined $ord;
    }
    my $fsfile = CurrentFile();
    return $fsfile ? $fsfile->FS->order : undef;
}

=item C<NewRBrother(node)>

Create a new brother of the given node and recalculate the special FS
numbering attribute values in the whole tree so that the new node is
the first right sibling of the given node.

If no node is given, this function operates on C<$this> and B<resets>
C<$this> to the newly created node. If some node is given the value
of C<$this> is preserved.

=cut

sub NewRBrother {
## Adds new RBrother to current node and shifts
## ords of the other nodes appropriately
    my $ref = ref( $_[0] ) ? $_[0] : $this;

    return unless ( $ref and $ref->parent );
    my $nd  = Treex::PML::Factory->createNode();
    my $ord = _node_ord($ref);

    if ( defined $ord ) {
        $nd->{$ord} = $ref->{$ord} + 1;
        my $node = $ref->root;
        while ($node) {
            $node->{$ord}++
                if ( $node ne $nd and $node->{$ord} > $ref->{$ord} );
            $node = $node->following;
        }
        PasteNode( $nd, $ref->parent );
    }
    else {
        PasteNodeAfter( $nd, $ref );
    }
    $this = $nd unless ref( $_[0] );
    return $nd;
}

=item C<NewLBrother(node)>

Create a new brother of the given node and recalculate the special FS
numbering attribute values in the whole tree so that the new node is
the first left sibling of the given node.

If no node is given, this function operates on C<$this> and B<resets>
C<$this> to the newly created node. If some node is given the value
of C<$this> is preserved.

=cut

sub NewLBrother {
## Adds new RLrother to current node and shifts
## ords of the other nodes appropriately
    my $ref = ref( $_[0] ) ? $_[0] : $this;
    return unless ( $ref and $ref->parent );
    my $nd  = Treex::PML::Factory->createNode();
    my $ord = _node_ord($ref);
    if ( defined $ord ) {
        $nd->{$ord} = $ref->{$ord};
        my $node = $ref->root;
        while ($node) {
            $node->{$ord}++
                if ( $node ne $nd and $node->{$ord} >= $ref->{$ord} );
            $node = $node->following;
        }
        PasteNode( $nd, $ref->parent );
    }
    else {
        PasteNodeBefore( $nd, $ref );
    }
    $this = $nd unless ref( $_[0] );
    return $nd;
}

=item C<NewSon(parent)>

Create a new child of the given parent node and recalculate the
special FS numbering attribute values in the whole tree so that the
new node is the first node right to the given parent.

If no parent node is given, this function operates on C<$this> and
B<resets> C<$this> to the newly created node. If a parent node is
given the value of C<$this> is preserved.

=cut

sub NewSon {
## Adds new son to current node and shifts
## ords of the other nodes appropriately
    my $ref = ref( $_[0] ) ? $_[0] : $this;
    return unless ($ref);
    my $nd  = Treex::PML::Factory->createNode();
    my $ord = _node_ord($ref);
    if ( defined $ord ) {
        $nd->{$ord} = $ref->{$ord} + 1;
        my $node = $ref->root;
        while ($node) {
            $node->{$ord}++ if ( $node->{$ord} > $ref->{$ord} );
            $node = $node->following;
        }
    }
    PasteNode( $nd, $ref );
    $this = $nd unless ref( $_[0] );
    return $nd;
}

=item C<NewParent(node)>

Create a node between given node and its parent and recalculate the
special FS numbering attribute values in the whole tree so that the
new node is the first node left to the given node.

If no node is given, this function operates on C<$this> and
B<resets> C<$this> to the newly created node. If a parent node is
given the value of C<$this> is preserved.

=cut

sub NewParent {
    my $ref = ref( $_[0] ) ? $_[0] : $this;
    return unless ($ref);
    my $nd  = Treex::PML::Factory->createNode();
    my $ord = _node_ord($ref);
    if ( defined $ord ) {
        $nd->{$ord} = $ref->{$ord};
        my $node = $ref->root;
        while ($node) {
            $node->{$ord}++ if ( $node->{$ord} >= $ref->{$ord} );
            $node = $node->following;
        }
    }
    if ( $ref->parent ) {
        if ( defined $ord ) {
            PasteNode( $nd, $ref->parent );
        }
        else {
            PasteNodeAfter( $nd, $ref );
        }
        CutNode($ref);
        PasteNode( $ref, $nd );
    }
    else {    # root of the tree
        my $fsfile = CurrentFile();
        my $trees  = $fsfile->treeList();
        my $n      = Index( $trees, $ref );
        if ( $n < 0 ) {
            die "tree not found in the current Treex::PML::Document";
        }
        else {
            $fsfile->set_tree( $nd, $n );
        }
        PasteNode( $ref, $nd );
    }
    $this = $nd unless ref( $_[0] );
    return $nd;
}

=item C<DeleteThisNode()>

Delete the current (C<$this>) node and recalculate the special FS
numbering attribute values in the whole tree so that there is no gap
in the numbering. If the current node is not a leaf or if it is the
root of the current tree, this macro does nothing.

=cut

sub DeleteThisNode {
    return unless $this and $this->parent;
    my $p = $this->parent;
    if ( DeleteLeafNode($this) ) {
        $this = $p;
    }
}

=item C<DeleteLeafNode(node)>

Delete a leaf node and recalculate the special FS numbering attribute
values in the whole tree so that there is no gap in the numbering. If
a given node is not a leaf, this macro does nothing.

=cut

sub DeleteLeafNode {
## Deletes a given node and shifts
## ords of the other nodes appropriately
    shift unless ref( $_[0] );
    my $n = $_[0] || $this;
    return unless ($n);
    my $ord = _node_ord($n);
    if ( length $ord ) {
        my $order = $n->{$ord};
        my $node  = $n->root;
        if ( $n->destroy_leaf ) {
            while ($node) {
                $node->{$ord}-- if ( $node->{$ord} > $order );
                $node = $node->following;
            }
            return 1;
        }
        else {
            return 0;
        }
    }
    else {
        return $n->destroy_leaf() ? 1 : 0;
    }
}

=item C<DeleteSubtree(node)>

Deletes a whole node's subtree and recalculate the special FS
numbering attribute values in the whole tree so that there is no gap
in the numbering.

=cut

sub DeleteSubtree {
    shift unless ref( $_[0] );
    my $n = $_[0] || $this;
    my $top = $n->root;
    if ( PlainDeleteSubtree($n) ) {
        my $ord = _node_ord($top);
        if ( $ord ne "" ) {
            my $i = 0;
            for my $node ( sort { $a->{$ord} <=> $b->{$ord} } $top,
                $top->descendants )
            {
                $node->{$ord} = $i++;
            }
        }
    }
}

=item C<RemoveTree(n?,fsfile?)>

Removes n-th tree from a given L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> (trees are numbered starting from 0).
If no L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> is specified, uses the current file (see CurrentFile()).

Calling RemoveTree() without arguments, it is equivalent to

  RemoveTree(CurrentTreeNumber(),CurrentFile())

Returns the deleted tree. If you do not reattatch the tree to the L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>,
use $tree->destroy method on the returned tree to prevent a memory leak.

=cut

sub RemoveTree {
    shift if @_ == 1 and $_[0] !~ /^\D/;    # class name
    my ( $no, $fsfile ) = @_;
    croak("RemoveTree: must specify tree number!")
        if defined($fsfile)
            and !defined($no);
    $no = CurrentTreeNumber() if !defined $no;
    my $fs = $fsfile || CurrentFile();
    my $res = $fs->delete_tree($no);
    if ( $fs == CurrentFile() ) {
        $no            = CurrentTreeNumber();
        $no            = max( 0, min( $no, $fs->lastTreeNo ) );
        $grp->{treeNo} = $no;
    }
    return $res;
}

=item C<DestroyTree(n?,fsfile?)>

Like RemoveTree but immediatelly destroys the removed tree. Returns 1
on success.

=cut

sub DestroyTree {
    my $tree = &RemoveTree;
    if ($tree) {
        $tree->destroy;
        return 1;
    }
    return;
}

=item C<DetermineNodeType($node)>

For trees with L<Treex::PML::Schema|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Schema.pm>-based node typing, try to determine the type
of the node from the type of its parent, and associate the node with
the type (using $node->set_type). If there are more possibilities, the
user is asked to choose the correct type.

=cut

sub DetermineNodeType {
    my ($node) = @_;
    main::determineNodeType( $grp, $node );
}

=item C<CopyValues()>

Copy the values of all the attributes except the special FS numbering
attribute of the current node to a global hash variable named
%ValuesClipboard.

=cut

my %ValuesClipboard = ();

sub CopyValues {
    undef %ValuesClipboard;
    my @attrs = Attributes( $this, 1 );
    foreach my $atr (@attrs) {
        $ValuesClipboard{$atr} = Treex::PML::CloneValue( $this->{$atr} );
    }
    delete $ValuesClipboard{ _node_ord($this) };    # we do not copy this
        #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
}

=item C<PasteValues()>

Replace existing values of the current node's attributes by all values
stored in the global hash variable named %ValuesClipboard. The
function does not perform any node-type validity checks.

=cut

sub PasteValues {
    foreach my $key ( keys(%ValuesClipboard) ) {
        $this->{$key} = $ValuesClipboard{$key};
    }
}

=item C<PlainNewSon(parent)>

Add a new child node to the given parent and make it the current
node (by setting C<$this> to point to it).

=cut

sub PlainNewSon {
## Adds new son to a given parent
    my $parent = shift;
    return unless ($parent);
    my $nd = Treex::PML::Factory->createNode();
    PasteNode( $nd, $parent );
    return $this = $nd;
}

=item C<PlainDeleteNode()>

Delete the given node. The node must be a leaf of the tree (may not
have any children) and must have a parent (may not be the root of the
tree).

=cut

sub PlainDeleteNode {
## Deletes given node
    my $node = shift;
    return unless ( $node and $node->parent );

    $this = $this->parent if ( $node == $this );
    return $node->destroy_leaf();
}

=item C<PlainDeleteSubtree(node)>

Cut a the given node's subtree and destroy all its nodes.
This macro does not recalculate ordering attributes.

=cut

sub PlainDeleteSubtree {
    shift unless ref( $_[0] );
    my $n = $_[0] || $this;
    return 0 unless ( $n and $n->parent );
    $n->destroy();
    return 1;
}

=item C<NormalizeOrds(listref)>

Adjusts the special FS numbering attribute of every node of the list
referenced by the listref argument so that the value for the attribute
corresponds to the order of the node in the list and repaste each node
so that the structural order corresponds with this new numbering.

If no numbering FS numbering attribute is available, all this macro
does is to ensure that the structural order of sibling nodes
corresponds to their order in the given list.

=cut

sub NormalizeOrds {
    my ($nodesref) = @_;
    return unless @$nodesref > 0;
    my $ord = _node_ord( $nodesref->[0] );
    if ( defined($ord) and length($ord) ) {
        my $i = 0;
        for my $node (@$nodesref) {
            $node->{$ord} = $i++;
        }
        for my $node (@$nodesref) {
            RepasteNode($node);
        }
    }
    else {

        # this is tricky, all we can do here is to reorder siblings
        my %by_parent;
        my $p;
        for my $node (@$nodesref) {
            if ( $p = $node->parent ) {
                push @{ $by_parent{$p} }, $node;
            }
        }
        foreach my $group ( values %by_parent ) {
            if ( @$group > 1 ) {
                my $prev;
                foreach my $node (@$group) {
                    if ($prev) {
                        CutPasteAfter( $node, $prev );
                    }
                    else {
                        CutPaste( $node, $node->parent );
                    }
                    $prev = $node;
                }
            }
        }
    }
}

=item C<SortByOrd(listref)>

Sort the list of nodes referenced by the listref argumnt according to
the values of the special FS numbering attribute.

=cut

sub SortByOrd {
    my ($nodesref) = @_;
    my $ord = _node_ord( $nodesref->[0] );
    if ( defined $ord ) {
        local ( $a, $b );
        @$nodesref = sort { $a->{$ord} <=> $b->{$ord} } @$nodesref;
    }
    return $nodesref;
}

=item C<RepasteNode(node)>

Cut the given node and paste it immediately on the same parent so that
its structural position between its parent children is brought to
correspondence with the values of the special FS numbering attribute.

=cut

sub RepasteNode {
    my ($node) = @_;
    my $parent = $node->parent;
    return unless $parent;
    CutPaste( $node, $parent );
}

=item C<ShiftNodeRightSkipHidden(node)>

Shift the current node in the tree to the right leaping over all
hidden subtress by modifying the tree structure and value of the
special FS numbering attribute appropriately.

=cut

sub ShiftNodeRightSkipHidden {
    my ($node) = @_;
    return unless $node;
    my $ord = _node_ord($node);
    if ( defined($ord) and length($ord) ) {
        my @all = GetNodes();
        SortByOrd( \@all );

        # This is sideeffect, but
        # whe want to do this anyway
        NormalizeOrds( \@all );

        #
        #
        my $n = $node->{$ord};
        return $n if ( $n == $#all );

        my @vis = GetVisibleNodes();
        SortByOrd( \@vis );
        my $m = Index( \@vis, $node );
        return unless ( defined($m) and $m < $#vis );
        my $x = min( Index( \@all, $vis[ $m + 1 ] ), $#all );
        for ( my $i = $n + 1; $i <= $x; $i++ ) {
            $all[$i]->{$ord}--;
        }
        $node->{$ord} = $x;
        RepasteNode($node);
    }
    elsif ( $node->parent ) {
        my $rb = $node->rbrother;
        $rb = $rb->rbrother while ( $rb and IsHidden($rb) );
        CutPasteAfter( $node, $rb ) if $rb;
    }
}

=item C<ShiftNodeLeftSkipHidden(node,min?)>

Shift the current node in the tree to the left leaping over all hidden
subtress by modifying the tree structure and value of the special FS
numbering attribute appropriately. The optional argument min may be
used to specify the minimum left boundary for the value of the
ordering attribute of node.

=cut

sub ShiftNodeLeftSkipHidden {
    my ( $node, $min ) = @_;    # min sets the minimum left...
    return unless $node;
    my $ord = _node_ord($node);    # ... boundary for Ord
    if ( defined($ord) and length($ord) ) {
        my @all = GetNodes();
        SortByOrd( \@all );

        # This is a side-effect, but
        # we want to do it anyway
        NormalizeOrds( \@all );

        #
        #
        my $n = $node->{$ord};
        return $n if ( $n == 0 );

        my @vis = GetVisibleNodes();
        SortByOrd( \@vis );
        my $m = Index( \@vis, $node );
        return unless ( defined($m) and !defined($min) || $m > $min );
        my $x = max( Index( \@all, $vis[ $m - 1 ] ), 0 );
        for ( my $i = $n - 1; $i >= $x; $i-- ) {
            $all[$i]->{$ord}++;
        }
        $node->{$ord} = $x;
        RepasteNode($node);
    }
    elsif ( $node->parent ) {
        my $lb = $node->lbrother;
        $lb = $lb->lbrother while ( $lb and IsHidden($lb) );
        CutPasteBefore( $node, $lb ) if $lb;
    }
}

=item C<ShiftNodeRight(node)>

Shift the current node in the tree to the right by modifying the tree
structure and value of the special FS numbering attribute
accordingly.

=cut

sub ShiftNodeRight {
    my ($node) = @_;
    return unless $node;

    my $ord = _node_ord($node);
    if ( defined($ord) and length($ord) ) {
        my @all = GetNodes();
        SortByOrd( \@all );

        # This is a side-effect, but
        # we want to do it anyway
        NormalizeOrds( \@all );

        #
        #

        my $n = $node->{$ord};
        return $n if ( $n == $#all );
        $all[ $n + 1 ]->{$ord} = $n;
        $node->{$ord} = $n + 1;
        RepasteNode($node);
    }
    elsif ( $node->parent ) {
        my $rb = $node->rbrother;
        CutPasteAfter( $node, $rb ) if $rb;
    }
}

=item C<ShiftNodeLeft(node)>

Shift the current node in the tree to the right by modifying the tree
structure and value of the special FS numbering attribute
appropriately.

=cut

sub ShiftNodeLeft {
    my ($node) = @_;
    return unless $node;
    my $ord = _node_ord($node);
    if ( defined($ord) and length($ord) ) {
        my @all = GetNodes();
        SortByOrd( \@all );

        # This is sideeffect, but
        # whe want to do this anyway
        NormalizeOrds( \@all );

        #
        #

        my $n = $node->{$ord};
        return $n if ( $n == 0 );

        $all[ $n - 1 ]->{$ord} = $n;
        $node->{$ord} = $n - 1;
        RepasteNode($node);
    }
    elsif ( $node->parent ) {
        my $lb = $node->lbrother;
        CutPasteBefore( $node, $lb ) if $lb;
    }
}

=item C<GetNodesExceptSubtree(node)>

Returns the reference to an array containing the whole tree except the
nodes strictly in the subtrees of nodes given in an array referenced
by the parameter. (The returned array does contain the nodes passed in
the parameter.)

=cut

sub GetNodesExceptSubtree ($) {
    my $tops = shift;
    return unless ref( $tops->[0] );
    my @all;
    my $node = $root;

    # @all is filled the the visible nodes of the whole tree
    while ($node) {    # except for the nodes depending on the given node
        push @all, $node;
        if ( defined( Index( $tops, $node ) ) ) {
            $node = $node->following_right_or_up;
        }
        else {
            $node = $node->following;
        }
    }    #while
    return \@all;
}

=item C<MoveNode(source-node,target-node)>

Move the node specified by the first parameter after the node specified by
the second parameter in the ordering on nodes.

=cut

sub MoveNode ($$) {
    my ( $top, $after ) = @_;
    return unless ( ref($top) and ref($after) and ( $top != $after ) );
    my $all = [ GetNodes($top) ];
    SortByOrd($all);
    splice @$all, Index( $all, $top ),
        1;    # the top node is cut off from the array
    splice @$all, Index( $all, $after ) + 1, 0,
        $top;             # the top node is spliced after the appropriate node
    NormalizeOrds($all);  # the ordering attribute is modified accordingly
}

=item C<MoveSubtree(source-node,target-node)>

Move the subtree of the node specified by the first parameter after
the node specified by the second parameter in the ordering on
nodes. The subtree of the first argument is made contiguous in the
ordering on nodes, if it happens not to be so. (We use the fact that
the technical root node is always first in the ordering.)

=cut

sub MoveSubtree ($$) {
    my ( $top, $after ) = @_;
    return unless ( ref($top) and ref($after) and ( $top != $after ) );
    my $all = GetNodesExceptSubtree( [$top] );
    SortByOrd($all);
    splice @$all, Index( $all, $top ),
        1;    # the top node is cut off from the array
    my $subtree = [ GetNodes($top) ];
    SortByOrd($subtree);
    splice @$all, Index( $all, $after ) + 1, 0,
        @$subtree;         # the subtree is spliced after the appropriate node
    NormalizeOrds($all);   # the ordering attributes are modified accordingly
}

=back

=cut

###########################################################

=head2 Helper macros for attributes with list or alternatives of values

=over 4

=cut

=item C<CloneValue(value)>

Return an identical deep copy of a given scalar. Useful for copying
attribute values (and any value below them), including structured
attributes, lists or alternatives.

Warning: do not apply this macro to an entire L<Treex::PML::Node|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Node.pm> since otherwise
you might result with a copy of the complete tree, schema, etc.

=cut

=item C<IsList(value)>

Check that a given value is a list, i.e. L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object.

=cut

sub IsList {
    return 1 if UNIVERSAL::DOES::does( $_[0], 'Treex::PML::List' );
}

=item C<IsAlt(value)>

Check that a given value is an alternative, i.e. L<Treex::PML::Alt|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Alt.pm> object.

=cut

sub IsAlt {
    return 1 if UNIVERSAL::DOES::does( $_[0], 'Treex::PML::Alt' );
}

=item C<IsSeq(value)>

Check that a given value is a sequence, i.e. L<Treex::PML::Seq|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Seq.pm> object.

=cut

sub IsSeq {
    return 1 if UNIVERSAL::DOES::does( $_[0], 'Treex::PML::Seq' );
}

=item C<List(value,value,...)>

Return a new list (L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object) populated with given values.

=cut

sub List {
    Treex::PML::Factory->createList( [@_], 1 );
}

=item C<Alt(value,value,...)>

Return a new alternative (L<Treex::PML::Alt|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Alt.pm> object) populated with given values.

=cut

sub Alt {
    Treex::PML::Factory->createAlt( [@_], 1 );
}

=item C<AltV(value)>

If the value is an alternative (i.e. a L<Treex::PML::Alt|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Alt.pm> object), return
all its values. Otherwise return value.

=cut

sub AltV {
    UNIVERSAL::DOES::does( $_[0], 'Treex::PML::Alt' ) ? @{ $_[0] } : $_[0];
}

=item C<ListV(value)>

If the value is a list (i.e. a L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object), return
all its values. Otherwise return empty (Perl) list.

=cut

sub ListV {
    UNIVERSAL::DOES::does( $_[0], 'Treex::PML::List' ) ? @{ $_[0] } : ();
}

=item C<SeqV(value)>

If the value is a sequence (i.e. a L<Treex::PML::Seq|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Seq.pm> object), return all its
elements (L<Treex::PML::Seq::Element|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Seq/Element.pm> objects). Otherwise return empty (Perl)
list.

=cut

sub SeqV {
    UNIVERSAL::DOES::does( $_[0], 'Treex::PML::Seq' ) ? $_[0]->elements : ();
}

=item C<AddToAlt(node,attr,value,value...)>

Add given values as alternatives to the current value of
C<$node-E<gt>{$attr}>.  If only one value is given and C<$node-E<gt>{$attr}> is
empty or same as value, the given value is simply assigned to it. If
C<$node-E<gt>{$attr}> is a L<Treex::PML::Alt|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Alt.pm> object, the new values are simply added
to it. Otherwise, if C<$node-E<gt>{$attr}> is a simple value, C<$node-E<gt>{$attr}>
is set to a new L<Treex::PML::Alt|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Alt.pm> object containing the original value as
well as the given values.

=cut

sub AddToAlt {
    my ( $node, $attr ) = ( shift, shift );
    if ( $node->{$attr} eq "" ) {
        if ( @_ > 1 ) {
            $node->{$attr}
                = Treex::PML::Factory->createAlt( [ uniq(@_) ], 1 );
        }
        else {
            $node->{$attr} = $_[0];
        }
    }
    elsif ( IsAlt( $node->{$attr} ) ) {
        @{ $node->{$attr} } = uniq( @{ $node->{$attr} }, @_ );
    }
    else {
        $node->{$attr}
            = Treex::PML::Factory->createAlt( [ $node->{$attr}, @_ ], 1 );
    }
}

=item C<AddToList(node,attr,value,value,...)>

Add values to a given attribute. If C<$node-E<gt>attr($attr)> is not defined or
empty, a new L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> containing given values is created. If
C<$node-E<gt>attr($attr)> is a L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object, given values are simply added
to it. Error is issued if C<$node-E<gt>attr($attr)> is defined, non-empty, yet not
a L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object.

=cut

sub AddToList {
    my ( $node, $attr ) = ( shift, shift );
    my $val = $node->attr($attr);
    if ( IsList($val) ) {
        push @$val, @_;
    }
    elsif ( $val eq "" ) {
        $val = Treex::PML::Factory->createList( [@_], 1 );
        $node->set_attr( $attr, $val, 1 );
    }
    else {
        die
            "AddToList: Attribute '$attr' contains a non-empty non-list value. Refusing to add to '$val'!\n";
    }
}

=item C<AddToListUniq(node,attr,value,value,...)>

Add values to a given attribute, unless already present among the
current values. If C<$node-E<gt>attr($attr)> is not defined or empty,
a new L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> containing given values is created. If
C<$node-E<gt>attr($attr)> is a L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object, given values are
simply added to it. Error is issued if C<$node-E<gt>attr($attr)> is
defined, non-empty, yet not a L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object.

=cut

sub AddToListUniq {
    my ( $node, $attr ) = ( shift, shift );
    my $val = $node->attr($attr);
    if ( IsList($val) ) {
        @$val = uniq( @$val, @_ );
    }
    elsif ( $val eq "" ) {
        $val = Treex::PML::Factory->createList( [ uniq(@_) ] );
        $node->set_attr( $attr, $val, 1 );
    }
    else {
        die
            "AddToList: Attribute '$attr' contains a non-empty non-list value. Refusing to add to '$val'!\n";
    }
}

=item C<AddToSeq(node, attr, name => value, name => value,...)> or C<AddToSeq(node, attr, element, ...)>

Add elements to a given sequence attribute. If C<$node-E<gt>attr($attr)> is not defined or
empty, a new L<Treex::PML::Seq|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Seq.pm> object containing given name-value pairs (L<Treex::PML::Seq::Element|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Seq/Element.pm> objects) is created. If
C<$node-E<gt>attr($attr)> is a L<Treex::PML::Seq|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Seq.pm> object, given elements are simply added
to it. Error is issued if C<$node-E<gt>attr($attr)> is defined, non-empty, yet not
a L<Treex::PML::Seq|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Seq.pm> object.

=cut

sub AddToSeq {
    my ( $node, $attr ) = ( shift, shift );
    my $val = $node->attr($attr);
    unless ( IsSeq($val) ) {
        if ( !defined($val) or !length($val) ) {
            $val = Treex::PML::Factory->createSeq();
            $node->set_attr( $attr, $val, 1 );
        }
        else {
            die
                "AddToSeq: Attribute '$attr' contains a non-empty non-sequence value. Refusing to add to '$val'!\n";
        }
    }
    while (@_) {
        if ( UNIVERSAL::DOES::does( $_[0], 'Treex::PML::Seq::Element' ) ) {
            $val->push_element_obj(shift);
        }
        else {
            $val->push_element( ( shift, shift ) );
        }
    }
}

=back

=head2 General-purpose list functions

=over 4

=cut

sub uniq {
    return &TrEd::Utils::uniq;
}

=item C<Index(array-ref,item)>

A helper function which returns the index of the first occurence of a
given item in an array. Returns nothing (empty list) if the item is
not found. Note: 'eq' is used for comparison.

=cut

# imported from Treex::PML

=item C<ListIntersect(array-ref,array-ref,...)>

Compute intersection of given lists. In scalar context returns an
array-ref, in list context returns a list. All duplicities are
removed.

=cut

sub ListIntersect {
    my %counts;
    my $first = shift;
    $counts{$_}++ for ( map {@$_} @_ );
    my $count = scalar(@_);
    my @res = uniq grep { $counts{$_} == $count } @{$first};
    return wantarray ? @res : List(@res);
}

=item C<ListSubtract(array-ref, array-ref)>

Return elements occuring in the first list but not in the second list.
In scalar context returns a L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object (array-ref), in list
context returns a list. All duplicities are removed.

=cut

sub ListSubtract($$) {
    my %a;
    @a{ @{ $_[1] } } = ();
    my @res = grep { !exists( $a{$_} ) ? $a{$_} = 1 : 0 } @{ $_[0] };
    return wantarray ? @res : List(@res);
}

=item C<ListUnion(array-ref, array-ref, ...)>

Return union of given lists. In scalar context returns an array-ref,
in list context returns a L<Treex::PML::List|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/List.pm> object (array-ref). All
duplicities are removed.

=cut

sub ListUnion {
    my @res = uniq map @$_, @_;
    return wantarray ? @res : List(@res);
}

=item C<ListRegroupElements(array-ref, array-ref, ...)>

This is rotate-matrix like operation. The input is a list of
rows (array-refs each representing a row in a matrix); the output
is a list of columns in the matrix (a list of array-refs, each
representing a column in the matrix).

=cut

sub ListRegroupElements {
    my @r;
    for ( my $row = 0; $row < @_; $row++ ) {
        for ( my $col = 0; $col < @{ $_[$row] }; $col++ ) {
            $r[$col][$row] = $_[$row][$col];
        }
    }
    return wantarray ? @r : List(@r);
}

=back


=cut

=head2 GUI-related macros

=over 4

=cut

=item C<GUI()>

Return a reference if running from TrEd, i.e., GUI is available;
otherwise return C<undef>. If running from TrEd the returned value is
a TrEd::Window object representing the currently focused window.

=cut

sub GUI {
    return ( ref $grp eq 'TrEd::Window' ) ? $grp : undef;
}

=item C<CloseGUI()>

This macro is only available in TrEd. It closes TrEd's main window and
exits.

=cut

sub CloseGUI {
    my $win = GUI();
    if ($win) {
        ToplevelFrame()->afterIdle( [ \&main::quit, $win ] );
        $Redraw = 'none';
        ChangingFile(0);
    }
}

=item C<TrEdWindows()>

Return a list of TrEd::Window objects representing current TrEd
windows.

=cut

sub TrEdWindows {
    return @{ $grp->{framegroup}{treeWindows} };
}

=item C<CurrentWindow()>

Return a TrEd::Window object representing the currently focused
window.

=cut

sub CurrentWindow { return $grp->{framegroup}{focusedWindow} }

=item C<SetCurrentWindow(win)>

Focus a given window.

=cut

sub SetCurrentWindow {
    shift unless ref( $_[0] );
    my $win = shift || $grp;
    if ( ( blessed($win) and $win->isa('TrEd::Window') ) ) {
        my $tred = $grp->{framegroup};
        unless ( $win == $tred->{focusedWindow} ) {
            main::focusCanvas( $win->canvas, $tred );
        }
        $win = $tred->{focusedWindow};
        unless ( $grp == $win ) {
            $grp  = $win;
            $this = $win->{currentNode};
            $root = $win->{root};
        }
        return ( $grp == $win ) ? 1 : 0;
    }
    else {
        die
            "Usage: SetCurrentWindow(\$win) (argument is not a TrEd::Window)!";
    }
}

=item C<SplitWindowHorizontally(\%opts?)>

Split current window horizontally. Returns an object represening the
newly created window.

An optional HASHref with the following options can be passed as an argument:

=over 8

=item no_focus => 0|1

do not focus the new view (default value is 1)

=item no_init => 0|1

do not initialize the new view with the file, context, etc. from the
current vie (default value is 0)

=item no_redraw => 0|1

do not redraw the new view

=item ratio => float

A float value between 0 and 1 indicating the ratio of the height of
the new view to the current height of the active view.

=back

=cut

sub SplitWindowHorizontally {
    shift unless ref $_[0];
    return main::splitWindow(
        $grp->{framegroup},
        'horiz',
        {   no_focus => 1,
            ref( $_[0] ) ? %{ $_[0] } : ()
        }
    );
}

=item C<SplitWindowVertically()>

Split current window horizontally. Returns an object represening the
newly created window.

An optional HASHref with the following options can be passed as an argument:

=over 8

=item no_focus => 0|1

do not focus the new view (default value is 1)

=item no_init => 0|1

do not initialize the new view with the file, context, etc. from the
current vie (default value is 0)

=item no_redraw => 0|1

do not redraw the new view

=item ratio => float

A float value between 0 and 1 indicating the ratio of the height of
the new view to the current height of the active view.

=back

=cut

sub SplitWindowVertically {
    shift unless ref $_[0];
    return main::splitWindow(
        $grp->{framegroup},
        'vert',
        {   no_focus => 1,
            ref( $_[0] ) ? %{ $_[0] } : ()
        }
    );
}

=item C<CloseWindow(win?)>

Close a given window, unless it is the last window that exists.  If no
window is given as an argument, try closing the current window.  If
the closed window was focused, then a next sibling window gets focus.

=cut

sub CloseWindow {
    shift unless ref( $_[0] );
    my $win = shift || $grp;
    main::removeWindow( $grp->{framegroup}, $win );
    SetCurrentWindow();
    return $grp;
}

=item C<CurrentFile(win?)>

Return a L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object representing the file currently open in a given
TrEd window or in the currently focused window if called without
arguments.

=cut

sub CurrentFile {
    shift if !ref $_[0];
    my $win = shift || $grp;
    my ($package, $filename, $line) = caller;
    # print "CurrentFile: win=$win called from $package $line ($filename )\n";

    if ($win) {
#        use Data::Dumper;
#        $Data::Dumper::Maxdepth = 1;
#        $Data::Dumper::Deparse = 1;
#        print "CurrentFile== " . Dumper($win->{FSFile}) . "\n";
#        if ($win->{FSFile}) {
#            print "file is " . $win->{FSFile}->filename() . "\n";
#        }
#        else {
#            print "no file\n";
#        }
        return $win->{FSFile};
    }
}

=item C<CurrentNodeInOtherWindow(win)>

Return the node currently active in a given window.

=cut

sub CurrentNodeInOtherWindow {
    shift unless ref( $_[0] );
    my $win = shift || $grp;
    if ($win) {
        return $win->{currentNode};
    }
    return;
}

=item C<SetCurrentNodeInOtherWindow(win,node)>

Set active node for a given window.

=cut

sub SetCurrentNodeInOtherWindow {
    my ( $win, $node ) = @_;
    TrEd::Window::TreeBasics::set_current( $win, $node );
}
*SetCurrentNodeInOtherWin
    = \&SetCurrentNodeInOtherWindow;    # compatibility alias

=item C<InVerticalMode()>

Return true if the tree is currently displayed in the vertical mode.

=cut

sub InVerticalMode {
    return $grp->treeView->get_verticalTree;
}

=item C<ToplevelFrame()>

Returns the Tk::Toplevel object containing the current window.

=cut

sub ToplevelFrame {
    return $grp && $grp->toplevel();
}

=item C<PrintDialog(...)>

See the description in the L<Printing trees> section.

=cut

=item C<Redraw($win?.$ignoreThis)>

Force TrEd to immediately redraw the current (or given) window. Hence
TrEd redraws the tree right after an interactively invoked macro
finishes, explicit calls to Redraw macro are needed rather rearly (for
example from a hook). If the flag $ignoreThis is used, then current
value of $this variable will not be used to determine the current node
of the window (i.e. $win->{currentNode}).

=cut

sub Redraw {
    _croak("Cannot call Redraw without a GUI\n") unless GUI();
    my $win        = shift() || $grp;
    my $ignoreThis = shift;
    my $ie         = $main::insideEval;
    $main::insideEval = 0;
    TrEd::Window::TreeBasics::set_current( $win, $this )
        if ( !$ignoreThis and $this );
    $win->get_nodes();
    $win->redraw();
    main::centerTo( $win, $this ) if ( !$ignoreThis and $this );
    main::update_title_and_buttons( $win->{framegroup} );
    $main::insideEval = $ie;
}

=item C<Redraw_FSFile()>

Force TrEd to immediately redraw all windows displaying current
file.

=cut

sub Redraw_FSFile {
    _croak("Cannot call Redraw without a GUI\n") unless GUI();
    my $ie = $main::insideEval;
    $main::insideEval = 0;
    TrEd::Window::TreeBasics::set_current( $grp, $this ) if ($this);
    my $fsfile     = CurrentFile();
    my $framegroup = $grp->{framegroup};
    main::get_nodes_fsfile( $framegroup, $fsfile );
    main::redraw_fsfile( $framegroup, $fsfile );
    main::centerTo( $grp, $this ) if ($this);
    main::update_title_and_buttons($framegroup);
    $main::insideEval = $ie;
}

=item C<Redraw_FSFile_Tree()>

Force TrEd to immediately redraw all windows displaying current
tree.

=cut

sub Redraw_FSFile_Tree {
    _croak "Cannot call Redraw without a GUI" unless GUI();
    my $ie = $main::insideEval;
    $main::insideEval = 0;
    my $fsfile     = CurrentFile();
    my $framegroup = $grp->{framegroup};
    TrEd::Window::TreeBasics::set_current( $grp, $this ) if ($this);
    main::get_nodes_fsfile_tree( $framegroup, $fsfile, $grp->{treeNo} );
    main::redraw_fsfile_tree( $framegroup, $fsfile, $grp->{treeNo} );
    main::centerTo( $grp, $this ) if ($this);
    main::update_title_and_buttons($framegroup);
    $main::insideEval = $ie;
}

=item C<Redraw_All()>

Force TrEd to immediately redraw all windows.

=cut

sub Redraw_All {
    _croak "Cannot call Redraw without a GUI" unless GUI();
    my $ie = $main::insideEval;
    $main::insideEval = 0;
    TrEd::Window::TreeBasics::set_current( $grp, $this ) if ($this);
    main::get_nodes_all( $grp->{framegroup} );
    main::redraw_all( $grp->{framegroup} );
    main::centerTo( $grp, $this ) if ($this);

    #TODO: toto je trocha divne imho
    main::update_title_and_buttons( $main::win->{framegroup} );
    $main::insideEval = $ie;
}

=item C<RedrawStatusLine()>

Force TrEd to immediately redraw status line.

=cut

sub RedrawStatusLine {
    _croak "Cannot call Redraw without a GUI" unless GUI();
    local $main::insideEval = 0;
    if ($this) {
        TrEd::Window::TreeBasics::set_current( $grp, $this );
        main::centerTo( $grp, $this );
    }
    $grp->{statusLine}->update_status($grp);
}

=item C<EditAttribute(node,attribute)>

Open edit attribute GUI.

=cut

sub EditAttribute {
    _croak "Cannot call EditAttribute without a GUI" unless GUI();
    main::doEditAttr( $grp, @_ );
}

=item C<Undo()>

Act as if the user pressed the undo button. Note that this macro also
changes $this and $root (since undo replaces the current tree with an
in-memory copy).

WARNING: Be aware that calling Undo() from a hook may conflict with
some macros, more specifically, with macros triggering such a hook
(indirectly, i.e. via some API call). In a case, changes to $this and
$root caused by Undo() do not propagate to the macro, which in turn
ends up working with incorrect (already replaced) nodes. Thus, if
calling Undo() within a hook, make sure to reset $this from
$grp->{currentNode} and $root from $this->root after all calls from
your macros which may possibly invoke the hook.

=cut

sub Undo {
    main::undo($grp);
    $this = $grp->{currentNode};
    $root = $this->root if $this;
    ChangingFile(0);
}

=item C<Redo()>

Act as if the user pressed the undo button. Note that this macro also
changes $this and $root.

=cut

sub Redo {
    main::re_do($grp);
    $this = $grp->{currentNode};
    $root = $this->root if $this;
    ChangingFile(0);
}

=item C<SaveUndo(comment)>

Save a snapshot of the current tree so that following operations on it
can be reverted with Undo. The C<comment> argument should provide
user-visible one-line diescription of the action following SaveUndo.

=cut

sub SaveUndo {
    $grp->{currentNode} = $this;
    main::save_undo( $grp, main::prepare_undo( $grp, 'Macro: ' . $_[0] ) );
}

=item C<ForgetRedo()>

Disable redo. This is useful if you programmatically Undo user's
action and do not want the user to be able to redo the action with
Redo.

=cut

sub ForgetRedo {
    my $stack = FileAppData('undostack');
    if ($stack) {
        splice @$stack, FileAppData('undo') + 1;    # remove redo
    }
}

=item C<Find()>

Open the Find Node by Attributes GUI dialog.

=cut

sub Find {
    _croak "Cannot call Find without a GUI" unless GUI();
    $grp->{framegroup}->{findButton}->invoke();
    $this = $grp->{currentNode};

    #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
}

=item C<FindNext()>

Searches for the first node matching the criteria of the previous use
of the Find... menu command or FindNode macro usage.

=cut

sub FindNext {
    _croak "Cannot call FindNext without a GUI" unless GUI();
    $grp->{framegroup}->{findNextButton}->invoke();
    $this = $grp->{currentNode};

    #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
}

=item C<FindPrev()>

Searches for the previous node matching the criteria of the previous
use of the Find... menu command or FindNode macro usage.

=cut

sub FindPrev {
    _croak "Cannot call FindPrev without a GUI" unless GUI();
    $grp->{framegroup}->{findPrevButton}->invoke();
    $this = $grp->{currentNode};

    #  $FileNotSaved=0 if ($FileNotSaved eq '?');;
}

=item C<ErrorMessage(message)>

In TrEd, show a dialog box containing the given error-message in a
text window.  In BTrEd print the error message on standard error output.

=cut

sub ErrorMessage {
    TrEd::Error::Message::error_message( $grp, join( "", @_ ), 1 );
}

=item C<InfoMessage(message)>

In TrEd, show a dialog box containing the given info-message in a
text window.  In BTrEd print the message on standard output.

=cut

sub InfoMessage {
    my $message = join( "", @_ );
    if ( GUI() ) {
        ToplevelFrame()->ErrorReport(
            -title   => 'Information',
            -msgtype => 'INFO',
            -message => '',
            -body    => $message,
        );
    }
    else {
        print STDERR $message;
    }
}

=item C<StandardTredFont()>

Return a string or Tk::Font object representation of the font used in
TrEd to label tree-nodes.

=cut

sub StandardTredFont {
    return $main::font;
}

=item C<StandardTredValueLineFont()>

Return a string or Tk::Font object representation of the font used in
TrEd to display the "sentence" above the tree.

=cut

sub StandardTredValueLineFont {
    return $main::vLineFont;
}

=item C<CenterOtherWinTo(win,node)>

Center given window to a given node.

=cut

sub CenterOtherWinTo {
    my ( $win, $node ) = @_;
    main::centerTo( $win, $node );
}

=item C<HiddenVisible(win?)>

Return true if TrEd displays hidden nodes in a given window (or the
currently focused window if called without an argument).

=cut

sub HiddenVisible {
    shift unless ref( $_[0] );
    my $win = shift || $grp;
    return ( ref( $win->{treeView} ) and $win->{treeView}->get_showHidden() );
}

=item C<ToggleHiding($win?)>

If TrEd displays hidden nodes (or the currently focused window if
called without an argument), hide them and vice versa.

=cut

sub ToggleHiding {
    shift unless ref( $_[0] );
    my $win = shift || $grp;
    $win->{treeView}
        ->set_showHidden( int( !$win->{treeView}->get_showHidden ) );
}

=back

=cut

=cut

=head2 Create/modify keyboard shortcuts

=over 4

=cut

=item C<<< Bind( macro => bind-options,...) >>>

This macro can be used to dynamically create keyboard bindings and
menu items for user-defined macros in TrEd. The arguments consist of
one or more (macro => bind-options ) pairs
where macro is a subroutine name or a CODE reference and
bind-options is either a keyboard shortcut (e.g. 'Ctrl+a') or a HASH references
with the following keys and values (all optional):

=over 8

=item context

the binding context, e.g. the package in which context the macro is
evaluated. Only relevant if the macro is specified by name. If not
given, the caller package is used.

=item key

a keyboard binding for the macro (e.g. 'Ctrl+a'); if not given, no
keyboard binding is created.

=item menu

a label to be used for a menu-item created for the macro. If not
given, no menu-item is created for the macro.

=item changing_file

if the key C<changing_file> exists in the bind-options hash and its
value is I<value>, a call to the macro C<<< ChangignFile(I<value>) >>>
is made immediatelly after each invocation of the macro via this
binding.

=back

=cut

sub Bind {
    return unless GUI();
    while (@_) {
        my $macro = shift;
        my $bind;
        if ( @_ == 0 and ref($macro) eq 'HASH' ) {
            $bind  = $macro;
            $macro = $macro->{command};
        }
        else {
            $bind = shift;
        }
        my ($caller) = caller;
        if ( ref $bind eq 'HASH' ) {
            my $context = $bind->{context} || $caller;
            if ( exists $bind->{changing_file} ) {
                my $changes_file = $bind->{changing_file};
                my $old_macro    = $macro;
                if ( ref($old_macro) eq 'CODE' ) {
                    $macro = sub {
                        &$old_macro();
                        ChangingFile($changes_file);
                        }
                }
                else {
                    my ( $ctxt, $mac );
                    if ( $macro =~ /^(\w+)-\>(.*)/ ) {
                        $ctxt = $1;
                        $mac  = $2;
                    }
                    else {
                        $ctxt = $context;
                        $mac  = $old_macro;
                    }
                    $macro = sub {
                        $ctxt->$mac();
                        ChangingFile($changes_file);
                        }
                }
            }
            if ( $bind->{key} ) {
                TrEd::Macros::bind_key( $context, $bind->{key}, $macro );
            }
            if ( $bind->{menu} ) {
                TrEd::Macros::add_to_menu( $context, $bind->{menu}, $macro );
            }
        }
        elsif ( defined($bind) and !ref($bind) ) {
            TrEd::Macros::bind_key( $caller, $bind, $macro );
        }
        else {
            croak("Usage: Bind(macro => string|hash-ref, ...)");
        }
    }
}

=item C<UnbindBuiltin(key-binding)>

(TrEd only). Remove default TrEd's keybinding for a given key so that
custom macro can be bound to that key.
E.g. UnbindBuiltin('Ctrl+Home'); Note: use with care. Built-in
key-bining once removed cannot be restored (except by restarting TrEd).

=cut

sub UnbindBuiltin {
    return unless GUI();
    my ($key) = @_;
    $key =~ s/\+/-/g;                    # convert ctrl-x to ctrl+x
    $key =~ s/([^-]+-)/ucfirst($1)/eg;
    $key =~ s/Ctrl-/Control-/g;
    $grp->{framegroup}{top}->bind( 'my', "<$key>", undef );
}

# Function to be used instead of unbind_edit.inc
sub UnbindTreeEdit {
    return unless GUI();
    my ($context) = @_;
    my @keys
        = ( 'F7', 'Shift+F7', 'F8', 'F5', 'F6', 'Ctrl+Insert', 'Shift+Insert',
        );
    foreach my $key (@keys) {
        TrEd::Macros::unbind_key( $context, $key );
    }
}

=item C<OverrideBuiltinBinding(context,key-binding, binding_spec )>

(TrEd only). Get or modify default TrEd's keybinding.

The C<binding_spec> argument, if given, must be an array reference with two elements:

  [ sub { ... }, 'description' ]

WARNING: You have to be very careful when overriding a builtin
binding, since your code is not called as a macro or a hook! The routine is
called with the following three arguments:

  $tk_window, $grp->{framegroup}, $key

You may obtain $grp from the second argument using
$_[1]->{currentWindow}.  You should probably call Tk->break at the end
of your code, so that the event does not propagate. There is no
C<$root> or C<$this> available within the callback.

A safer way (with slower execution, though) is to use a macro wrapped
into a MacroCallback() instead of a sub:

 [ MacroCallback(...), 'description' ]

See C<MacroCallback> macro for details. The macro is called with the
same arguments (appended to a list of arguments provided in
C<MacroCallback>). The macro can use all standard macro functions and
variables.

If the C<context> argument is a name of a binding context, the binding
is only used in the specific context.  If C<context> is C<'*'>, the
binding applies to all contexts (except for contexts that specifically
overrid it).

If called without a binding_spec, the current binding_spec is returned, otherwise
the previous binding_spec is returned.

Example (swaps the behavior of normal C<left/right> with C<Shift+left/right>)

  my @keys = qw(Left Right);
  my %normal = map { $_ => OverrideBuiltinBinding('*',$_) } @keys;
  my %shift = map { $_ => OverrideBuiltinBinding('*',"Shift+$_") } @keys;
  for (@keys) {
    OverrideBuiltinBinding(__PACKAGE__, $_, $shift{$_});
    OverrideBuiltinBinding(__PACKAGE__, "Shift+$_", $normal{$_});
  }

Here is another example that changes the Up arrow to move to the
grand-parent instead of a parent:

  # Using TrEd internals (faster, but prone to changes in the internal API):

  OverrideBuiltinBinding(
    __PACKAGE__,
    'Up',
    [sub { main::currentUp($_[1]) for 1..2 },
    'Move to grand-parent']);

  # Using a macro (slower):

  OverrideBuiltinBinding(
    __PACKAGE__,
    "Up",
    [MacroCallback(sub { $this=$this->parent; $this=$this->parent if $this }),
    'Move to grand-parent']);

=cut

sub OverrideBuiltinBinding {
    return unless GUI();
    my ( $context, $key, $spec ) = @_;
    $key =~ s/\+/-/g;                    # convert ctrl-x to ctrl+x
    $key =~ s/([^-]+-)/ucfirst($1)/eg;
    $key =~ s/Ctrl-/Control-/g;
    my $grp = TrEd::Macros::get_macro_variable('grp');
    if ( defined $spec ) {
        if ( !TrEd::Binding::Default::binding_valid($spec) ) {
            croak(
                "OverrideBuiltinBinding: invalid binding for context $context, key <$key> , must be [code, description]!"
            );
        }

        # default_binding might not be constructed, so do it this way...
        return TrEd::Binding::Default::change_binding(
            $grp->{framegroup}->{default_binding},
            $context, $key, $spec );
    }
    else {

        # default_binding might not be constructed, so do it this way...
        return TrEd::Binding::Default::get_binding(
            $grp->{framegroup}->{default_binding},
            $context, $key );
    }
}

=item C<MacroCallback(macro_spec,@args)>

This macro can be used to safely wrap a given macro into a code that
can be used to override a TrEd builtin or passed as a callback to a Tk
widget.

The first argument can take one of the following forms:

  String:
    "macro_name" or "Package->macro_name"

  Anonymous subrutine:
    sub { ...code... }

  Hash reference:
    { -command => sub { ...code... },
      -changing_file => 0 | 1,
      -contex => 'PackageName'
    }

  Array reference:
    [ sub { ..code ...}, arg1, arg2, ...]

The macro is called with the arguments provided in the macro_spec,
followed by the arguments provided in the call to MacroCallback,
followed by arguments passed by the caller (e.g. TrEd or the Tk
widget).

=cut

sub MacroCallback {
    my ( $binding, @args ) = @_;
    my $macro;
    my ($context) = caller;
    if ( ref($binding) eq 'HASH' ) {
        my $command = $binding->{command};
        $context = $binding->{context} || $context;
        return unless $command;
        if ( exists( $binding->{changing_file} ) ) {
            my $changes_file = $binding->{changing_file};
            if ( ref($command) eq 'CODE' ) {
                $macro = sub {
                    &$command(@_);
                    ChangingFile($changes_file);
                };
            }
            else {
                $macro = sub {
                    $context->$command(@_);
                    ChangingFile($changes_file);
                    }
            }
        }
        else {
            $macro = $command;
        }
    }
    else {
        $macro = $binding;
    }
    $macro
        = ( ref($macro) or $macro =~ /^\w+-\>/ )
        ? $macro
        : $context . '->' . $macro;
    my $mark;
    return [
        sub {
            my @cb_args;
            my $arg;
            while (@_) {
                $arg = shift @_;
                if ( defined($arg) and $arg != \$mark ) {
                    push @cb_args, $arg;
                }
                else {
                    last;
                }
            }
            my $tred = shift @_;
            my $m    = $macro;
            if ( @cb_args or @_ ) {
                if ( ref($m) eq 'ARRAY' ) {
                    push @$m, @cb_args, @_;
                }
                elsif ( ref($m) ) {
                    $m = [ $m, @cb_args, @_ ];
                }
                else {
                    $m = [ eval "sub { $m(\@_) }", @cb_args, @_ ];
                }
            }
            if ($main::insideEval) {
                main::do_eval_macro( $tred->{focusedWindow}, $m );
            }
            else {
                main::doEvalMacro( $tred->{focusedWindow}, $m );
            }
        },
        \$mark,
        $grp->{framegroup},
        @args
    ];
}

=back

=cut

###########################################################

=head2 Stylesheet API

=over 4

=item C<STYLESHEET_FROM_FILE()>

This function returns a symbolic name for a virtual stylesheet that is
constructed from the patterns and hint specified in the currently
displayed file.

=cut

sub STYLESHEET_FROM_FILE {&TrEd::Stylesheet::STYLESHEET_FROM_FILE}

=item C<SetStylesheetPatterns(patterns,stylesheet,create)>

Set TrEd's display patterns for a given stylesheet. If stylesheet is
undefined, then the stylesheet currently selected for the active view
is used. The patterns argument should either be a string or an array
reference.  If it is a string, then it should provide all the
patterns, each pattern starting on a new line (but possibly spanning
across several lines) which starts with a pattern prefix of the form
"something:", where "something" is hint for the hint pattern, or
"node" for the node pattern, etc.

Patterns can also be provided as an array reference containing three
elements: the first one being a hint text, the second the context
pattern (regular expression), and the second one an array reference
whose each element is the text of an individual pattern.

The create flag can be set to 1 in order to create a new stylesheet in
case that no stylesheet with the given exists.

This function returns 1 if success, 0 if failed (i.e. when create is
not set and a given stylesheet is not found).

=cut

sub SetStylesheetPatterns {
    my ( $patterns, $stylesheet, $create ) = @_;
    $stylesheet = GetCurrentStylesheet() unless defined $stylesheet;
    TrEd::Stylesheet::set_stylesheet_patterns( $grp, $patterns, $stylesheet,
        $create );
    if ( GUI() ) {
        main::redraw_stylesheet( $grp->{framegroup}, $stylesheet );
    }
    $Redraw = 'all';
}

=item C<DeleteStylesheet(stylesheet)>

Delete given stylesheet. All windows using that stylesheet are
switched to the pattern and hint specified in the respective files
they display.

=cut

sub DeleteStylesheet {
    my ($stylesheet) = @_;
    if ( GUI() ) {
        TrEd::Stylesheet::delete_stylesheet( $grp->{framegroup},
            $stylesheet );
    }
}

=item C<SaveStylesheet(name)>

Save given TrEd's stylesheet (to ~/.tred.d/stylesheets/name).

=cut

sub SaveStylesheet {
    my ( $patterns, $stylesheet ) = @_;
    TrEd::Stylesheet::save_stylesheet_file( $grp->{framegroup}, $stylesheet )
        if GUI();
}

=item C<SaveStylesheets()>

Save all TrEd's stylesheets (to ~/.tred.d/stylesheets/).

=cut

sub SaveStylesheets {
    my ($patterns) = @_;
    TrEd::Stylesheet::save_stylesheets( $grp->{framegroup} ) if GUI();
}

=item C<ReloadStylesheet(name,dir?)>

Reload a given stylesheet. If no dir is specified, the
default path "~/.tred.d/stylesheets/" is used.

=cut

sub ReloadStylesheet {
    my ( $name, $dir ) = @_;
    $dir = $main::defaultStylesheetPath unless defined $dir;
    if ( GUI() ) {
        require URI::Escape;
        my $file = File::Spec->catfile( $dir,
            URI::Escape::uri_escape_utf8($name) );
        TrEd::Stylesheet::read_stylesheet_file( $grp->{framegroup}, $file );
    }
}

=item C<ReloadStylesheets(dir?)>

Reload stylesheets from a given file or directory. If no filename is
specified, the default path "~/.tred.d/stylesheets/" is used.

=cut

sub ReloadStylesheets {
    my ($filename) = @_;
    TrEd::Stylesheet::load_stylesheets( $grp->{framegroup} ) if GUI();
}

=item C<GetStylesheetPatterns(stylesheet)>

For a given stylesheet, return it's patterns. In a scalar context,
returns a string consisting of all patterns, including the hint.  In
the array context returns three scalars: the first one containing the
text of the hint pattern, the second the context pattern (regexp) and
the other a reference to a list containing the stylesheet
patterns. Returns empty list in case of failure.

=cut

sub GetStylesheetPatterns {
    my ($stylesheet) = @_;
    return TrEd::Stylesheet::get_stylesheet_patterns( $grp, $stylesheet );
}

=item C<GetPatternsByPrefix(prefix,stylesheet?)>

Return all patterns of a given stylesheet starting with a given prefix.
If no stylesheet name is given, a current stylesheet is used.

=cut

sub GetPatternsByPrefix {
    my ( $prefix, $stylesheet ) = @_;
    my ( $hint, $context, $patterns )
        = TrEd::Stylesheet::get_stylesheet_patterns( $grp, $stylesheet );
    if ( $prefix eq 'hint' ) {
        return $hint;
    }
    elsif ( $prefix eq 'context' ) {
        return $context;
    }
    else {
        return
            map { /^\Q$prefix\E:\s*((?:.|\n)*?)\s*$/ ? $1 : () } @$patterns;
    }
}

=item C<StylesheetExists(stylesheet)>

Returns true if stylesheet with a given name exists.

=cut

sub StylesheetExists {
    return 1
        if exists( $grp->{framegroup}{stylesheets} )
            and exists( $grp->{framegroup}{stylesheets}{ $_[0] } );
}

=item C<Stylesheets()>

Returns a list of TrEd's stylesheet names.

=cut

sub Stylesheets {
    return ( keys( %{ $grp->{framegroup}{stylesheets} } ) );
}

=item C<GetCurrentStylesheet()>

Returns name of the stylesheet currently selected for the active
window.

=cut

sub GetCurrentStylesheet {
    return $grp->{stylesheet};
}

=item C<SetCurrentStylesheet(stylesheet_name)>

Set stylesheet for the active window.

=cut

sub SetCurrentStylesheet {
    my ($stylesheet_name) = @_;
    if ( StylesheetExists($stylesheet_name)
        or $stylesheet_name eq STYLESHEET_FROM_FILE() )
    {
        if ( $grp->{framegroup} && $grp->is_focused() ) {
            $grp->{framegroup}{selectedStylesheet} = $stylesheet_name;
        }
        return main::switchStylesheet( $grp, $stylesheet_name );
    }
    return -1;
}

=item C<GetSpecialPattern(prefix)> - OBSOLETE!!

This macro is obsoleted by GetPatternsByPrefix.

=cut

sub GetSpecialPattern {
    my ($patname) = @_;
    return unless CurrentFile();
    carp(
        "GetSpecialPattern is obsolete: use GetPatternsByPrefix('$patname',STYLESHEET_FROM_FILE()) instead"
    );
    my ($pat) = GetPatternsByPrefix( $patname, STYLESHEET_FROM_FILE() );
    return $pat;
}

=item C<SetDisplayAttrs(pattern,...)> - OBSOLETE!!

Setup given patterns as a stylesheet of
the currently displayed L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>. This does not include
a hint pattern.

=cut

sub SetDisplayAttrs {
    my $fsfile = CurrentFile();
    return unless $fsfile;
    carp(
        "SetDisplayAttrs is obsolete: use SetStylesheetPatterns([...],STYLESHEET_FROM_FILE()) instead"
    );
    $fsfile->changePatterns(@_);
}

=item C<SetBalloonPattern(string,...)> - OBSOLETE!!

Use given strings as a C<hint:> pattern for
the currently displayed L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>.

=cut

sub SetBalloonPattern {
    my $fsfile = CurrentFile();
    return unless $fsfile;
    $fsfile->changeHint( join "\n", @_ );
    carp(
        "SetBalloonPattern is obsolete: use SetStylesheetPatterns([...],STYLESHEET_FROM_FILE()) instead"
    );
}

=item C<GetDisplayAttrs()> - OBSOLETE!!

Get patterns of the currently displayed L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>'s stylesheet, except
for a C<hint:> pattern.

=cut

sub GetDisplayAttrs {
    my $fsfile = CurrentFile();
    return unless $fsfile;
    carp(
        "GetDisplayAttrs is obsolete: use GetStylesheetPatterns(STYLESHEET_FROM_FILE()) instead"
    );
    return $fsfile->patterns();
}

=item C<GetBalloonPattern()> - OBSOLETE!!

Get a C<hint:> pattern of the currently displayed
L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>'s stylesheet.

=cut

sub GetBalloonPattern {
    my $fsfile = CurrentFile();
    return unless $fsfile;
    carp(
        "GetBalloonPattern is obsolete: use (\$hint)=GetPatternsByPrefix('hint',STYLESHEET_FROM_FILE()) instead"
    );
    return $fsfile->hint();
}

=item C<CustomColor(name,new-value?)>

Get or set user defined custom color.

=cut

sub CustomColor {
    my ( $color, $value ) = @_;
    return unless GUI();
    if ( defined($value) ) {
        return $TrEd::Config::treeViewOpts->{customColors}->{$color} = $value;
    }
    else {
        $value = $TrEd::Config::treeViewOpts->{customColors}->{$color};
        return $value;
    }
}

=item C<UserConf(name,new-value?)>

Get or set value of a user defined configuration option.

=cut

sub UserConf {
    my ( $name, $value ) = @_;
    if ( @_ >= 1 ) {
        $TrEd::Config::userConf->{$name} = $value;
    }
    else {
        $TrEd::Config::userConf->{$name};
    }
}

=item C<AddStyle(styles,object,key =E<gt> value,...)>

Auxiliary funcion: add styles for an object to a given
style-hash (can be used e.g. from node_style_hook).

=cut

sub AddStyle {
    my ( $styles, $style, %s ) = @_;
    if ( exists( $styles->{$style} ) ) {
        $styles->{$style}{$_} = $s{$_} for keys %s;
    }
    else {
        $styles->{$style} = \%s;
    }
}

=item C<GetStyles(styles,object,$feature?)>

Auxiliary funcion: if feature is given, retrieves and returns a
feature of a particular object from the given style-hash.  If feature
is not given or undef, returns a (flat) list of feature => value pairs
consisting of the style features of a given type of object obtained
from the style-hash.

This function can be used e.g. from node_style_hook.

=cut

sub GetStyles {
    my $styles  = shift;
    my $style   = shift;
    my $feature = shift;
    unless ( defined($style) ) {
        carp(
            "Usage: GetStyles(\$styles,\$object_type,\$feature?), where \$object_type is e.g. 'Node', 'Oval', or 'Line'\n"
        );
    }
    my $s = $styles->{$style};
    if ( defined($s) ) {
        if ( defined $feature ) {
            return $s->{$feature};
        }
        else {
            return %$s;
        }
    }
    return;
}

=back

=cut

###########################################################

=head2 Context API

=over 4

=item C<CurrentContext()>

Return the name of the current macro context.

=cut

sub CurrentContext {
    return $grp->{macroContext};
}

=item C<SwitchContext(context)>

Switch to given macro context.

=cut

sub SwitchContext {
    main::switchContext( $grp, shift );
}

=item C<CurrentContextForWindow(win)>

Get a macro context currently selected in a given window.

=cut

sub CurrentContextForWindow {
    shift unless ref( $_[0] );
    my $win = shift || GUI();
    return $win ? $win->{macroContext} : undef;
}

=item C<SwitchContextForWindow(win,context)>

Switch given window to given macro context.

=cut

sub SwitchContextForWindow {
    shift unless ref( $_[0] );
    my $win = shift || GUI();
    if ($win) {
        my ( $ctxt, $no_redraw ) = @_;
        main::switchContext( $win, $ctxt, $no_redraw );
    }
}

=back

=cut

###########################################################

=head2 Treex::PML::FSFormat API

Here are described for working with L<Treex::PML::FSFormat|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/FSFormat.pm> objects. Beside these
macros, L<Treex::PML::FSFormat|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/FSFormat.pm> object methods can be used.

=over 4

=item C<FS()>

Return L<Treex::PML::FSFormat|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/FSFormat.pm> object associated with the current L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>.

=cut

sub FS {
    my $current_file = CurrentFile();
    if ( defined $current_file ) {
        return CurrentFile()->FS();
    }
    else {
        return;
    }
}

=item C<GetOrd(node)>

Return value of the special numbering FS attribute. This macro
actually returns the same value as
C<<< $node-E<gt>{FS()->order()} >>>

=cut

sub GetOrd { return $_[0]->{ _node_ord( $_[0] ) }; }

=item C<Attributes(node?,normal_fields?)>

If no node is given or the node is not associated with a type, return
a list of names of all attributes declared in the FS-file header or
Schema.

If node is associated with a type and the 2nd attribute is undef or
false, return list of paths to all its (possibly nested) atomic-value
attributes.  This is equivalent to

  $node->type->schema->attributes($node->type)

If node is associated with a type and the 2nd attribute is true,
return only first-level attribute names. This is equivalent to

  $node->type->get_normal_fields()

=cut

sub Attributes {
    my ( $node, $members_only ) = shift;
    if ( $node and $node->type ) {
        if ($members_only) {
            return $node->type->get_normal_fields();
        }
        else {
            return $node->type->schema->attributes( $node->type );
        }
    }
    else {
        my $fsfile = CurrentFile();
        return unless $fsfile;
        if ( ref( $fsfile->metaData('schema') ) ) {
            return $fsfile->metaData('schema')->attributes();
        }
        else {
            return $fsfile->FS->attributes;
        }
    }
}

=item C<SubstituteFSHeader(declarations)>

Substitute a new FS header for current document. A list of valid FS
declarations must be passed to this function.

=cut

sub SubstituteFSHeader {
    CurrentFile()->changeFS( FS()->create(@_) );
}

=item C<AppendFSHeader(declarations)>

Merge given FS header declarations with the present header
of the current document.

=cut

sub AppendFSHeader {
    my $new     = FS()->create(@_);
    my $newdefs = $new->defs();
    my $fsfile  = CurrentFile();
    my $fs      = $fsfile->FS;
    my $defs    = $fsfile->FS->defs();
    my $list    = $fsfile->FS->list();
    foreach ( $new->attributes() ) {
        push @$list, $_ unless ( $fs->exists($_) );
        $defs->{$_} = $newdefs->{$_};
    }
    @{ $fs->unparsed } = $fs->toArray() if $fs->unparsed;
}

=item C<UndeclareAttributes(attribute,...)>

Remove declarations of given attributes from the FS header

=cut

sub UndeclareAttributes {
    my $fsfile = CurrentFile();
    my $fs     = $fsfile->FS;
    my $defs   = $fsfile->FS->defs();
    my $list   = $fsfile->FS->list();
    delete @{$defs}{@_};

    @$list = grep { exists( $defs->{$_} ) } @$list;
    @{ $fs->unparsed }
        = grep { !/^\@\S+\s+([^\s|]+)/ || exists( $defs->{$1} ) }
        @{ $fs->unparsed }
        if $fs->unparsed;

}

=back

=cut

###########################################################

=head2 Treex::PML::Document I/O API

See also L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object methods defined in the L<Treex::PML|http://search.cpan.org/dist/Treex-PML> module.

=over 4

=item C<ChangingFile(0|1)>

If no argument given the default is 1. If C<$FileChanged> is already
set to 1, does nothing. If C<$FileChanged> has not yet been
assigned or is zero, sets it to the given value. Returns the resulting
value. C<ChangingFile(1)> also resets C<$forceFileSaved> to 0.

=cut

sub ChangingFile {
    my ($val) = @_;
    $val = 1 if !defined($val);
    if ( $FileChanged eq '?' ) {
        $FileChanged = $val;
    }
    elsif ( $FileChanged == 0 ) {
        $FileChanged = $val;
    }
    $forceFileSaved = 0 if ($val);
    return $FileChanged;
}

=item C<CurrentFile()>

Return a L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object representing the currently processed file.

=cut

=item C<Open(filename,flags)>

Open a given L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> in TrEd. Flags is an optional HASH reference
that may contain various flags internally used by TrEd.

=cut

sub Open {
    my ( $filename, $opts ) = @_;
    $opts ||= {};
    my $ret = TrEd::File::open_file( $grp, $filename, %$opts );
    if ( exists( $grp->{framegroup} ) ) {    # why?
        $root = $grp->{root};
        $this = $grp->{currentNode};
    }
    return $ret;
}

=item C<OpenSecondaryFiles($fsfile)>

Open secondary files for a given L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> in TrEd.

=cut

sub OpenSecondaryFiles {
    my ($fsfile) = @_;
    my $status = TrEd::File::open_secondary_files( $grp, $fsfile );
    unless ( $status->{ok} ) {
        die( $status->{error} );
    }
    return 1;
}

=item C<ReloadCurrentFile()>

Close and reload current fsfile.

=cut

sub ReloadCurrentFile {
    my $ret = TrEd::File::reload_file($grp);
    if ( exists( $grp->{framegroup} ) ) {    # why?
        $root = $grp->{root};
        $this = $grp->{currentNode};
    }
    return $ret;
}

=item C<Resume($fsfile)>

Resume a previously open fsfile a given window in TrEd.

=cut

sub ResumeFile {
    my ($fsfile) = @_;
    local $main::insideEval = 0;
    my $ret = TrEd::File::resume_file( $grp, $fsfile, 1 );
    main::doEvalHook( $grp, "file_resumed_hook" );
    return $ret;
}

=item C<CloseFile(file?)>

Close a given L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>.

=cut

sub CloseFile {
    shift unless ref( $_[0] );
    my $file = $_[0] || CurrentFile();
    croak("Not a Treex::PML::Document object!\n")
        if defined($file)
            and !UNIVERSAL::DOES::does( $file, 'Treex::PML::Document' );
    TrEd::File::close_file( $grp, -fsfile => $file );
    $Redraw = 'all';
}

=item C<CloseFileInWindow(window?)>

This macro is for TrEd only. It closes the L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> open in the given or
current window.  If the file is open in other windows, it is kept
among postponed files. If the file is modified, the user is asked to
save it.

=cut

sub CloseFileInWindow {
    shift unless ref( $_[0] );
    my $win = shift() || $grp;
    my $ret = GUI() && TrEd::File::close_file_in_window($win);
    $Redraw = 'all';
}

=item C<Save()>

Save the current L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>.

=cut

sub Save {
    my $ret = ( TrEd::File::save_file($grp) == 1 );
    $FileNotSaved   = GetFileSaveStatus();
    $forceFileSaved = !$FileNotSaved;
    return $ret;
}

=item C<SaveAs({ option=>value,... })>

NOTE: This macro is currently only available in TrEd.

Save the current L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> under a new filename.
Returns 1 if the file was saved successfully.

Options:

=over 6

=item filename

The new-filename. If undefined, the usual "Save As..." dialog prompts
the user to select the output filename.

=item fsfile

operate on a given fsfile rather than the current one

=item backend

save using a given I/O backend

=item update_refs

update references from other files to this file.  Values can be:
'ask', 'all', an array of L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> objects; all
other values mean no update. Default is 'ask'.

=item update_filelist

update references from the current filelist to this file.  Values can
be: 'ask', 'current' (update only the current position);
any other value means no update. Default is 'ask'.

=back

=cut

sub SaveAs {

    # TODO: implement in btred
    my ($opts) = @_;
    if ( !TrEd::Macros::is_defined('TRED') ) {
        _croak("SaveAs(): Not yet implemented!");
    }
    if ( !ref($opts) ) {
        $opts = { filename => $opts };
    }
    my $fsfile          = $opts->{fsfile}          || CurrentFile();
    my $filename        = $opts->{filename}        || $fsfile->filename;
    my $backend         = $opts->{backend}         || $fsfile->backend;
    my $update_refs     = $opts->{update_refs}     || 'ask';
    my $update_filelist = $opts->{update_filelist} || 'ask';

    my $ret = (
        TrEd::File::do_save_file_as(
            $grp,     $fsfile,      $filename,
            $backend, $update_refs, $update_filelist
            ) == 1
    );
    $FileNotSaved   = GetFileSaveStatus();
    $forceFileSaved = !$FileNotSaved;
    return $ret;
}

=item C<GetOpenFiles()>

Return a list of L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> objects currently open in TrEd (including
postponed files).

=cut

sub GetOpenFiles {
    if ( TrEd::Macros::is_defined('TRED') ) {
        return TrEd::File::get_openfiles();
    }
    else {
        return grep defined,
            ( $grp->{fsfile}, values %{ $grp->{preloaded} } );
    }
}

=item C<Backends()>

Return a list of currently registered I/O backends.

=cut

sub Backends {
    return TrEd::File::get_backends();
}

=item C<AddBackend($classname,$before_backend)>

Register a new I/O backend. Note that the caller is responsible for
loading the required module (e.g. by calling L<Treex::PML::ImportBackends|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/ImportBackends.pm>());
If $before_backend is defined, the new backend is added before a given
backend. Otherwise the backend is added as a last backend.

=cut

sub AddBackend {
    my $class  = shift;
    my $before = shift;
    TrEd::File::add_backend( $class, $before );
}

=item C<RemoveBackend($classname)>

Remove (unregister) a given backend.

=cut

sub RemoveBackend {
    my $class = shift;
    TrEd::File::remove_backend($class);
}

=item C<AddNewFileList($filelist)>

This macro is only available in TrEd.
Creates a new TrED filelist from a given C<Filelist> object.

=cut

#ifdef TRED
sub AddNewFileList {
    my ($fl) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    croak("Not a file-list object")
        unless UNIVERSAL::DOES::does( $fl, 'Filelist' );
    TrEd::ManageFilelists::add_new_filelist( $grp->{framegroup}, $fl );
}

#endif

=item C<RemoveFileList($filelist_object_or_name)>

This macro is only available in TrEd.  It disposes of a given filelist
(identified either by a C<Filelist> object or by name) by removing it
from TrEd's internal list of open filelists.

=cut

#ifdef TRED
sub RemoveFileList {
    my ($fl) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    $fl = GetFileList($fl) unless ref($fl);
    croak("No such file-list")
        unless UNIVERSAL::DOES::does( $fl, 'Filelist' );
    TrEd::ManageFilelists::deleteFilelist( $grp->{framegroup}, $fl );
}

#endif

=item C<GetCurrentFileList($win?)>

This macro is only available in TrEd. It returns the current file-list
(a Filelist object) of this or a given window.

=cut

#ifdef TRED
sub GetCurrentFileList {
    return if !TrEd::Macros::is_defined('TRED');
    my $win = $_[0] || $grp;
    return $win->{currentFilelist};
}

#endif

=item C<GetFileList($name)>

This macro is only available in TrEd.
Finds a filelist of a given name in TrEd's internal list open filelists
and returns the corresponding C<Filelist> object. Returns undef if not found.

=cut

#ifdef TRED
sub GetFileList {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    return unless defined $name;
    my @filelists = TrEd::ManageFilelists::get_filelists();
    return TrEd::MinMax::first { $_->name eq $name } @filelists;
}

#endif

=item C<AbsolutizeFileName($relative_path,$base_path)>

Converts a relative path to an absolute path.  The returned value is
an absolute path or URI, computed relative to a given base_path (file
name or URI). The function is able to strip TrEd position suffixes
(##N, ##N.M, and #ID) from the relative path and reattach them to the
returned absolute path.

=cut

sub AbsolutizeFileName {
    my ( $filename, $relfile ) = @_;
    return if !defined $filename;
    my $suffix;
    ( $filename, $suffix ) = TrEd::Utils::parse_file_suffix($filename);
    if ( defined $suffix ) {
        return Treex::PML::ResolvePath( $relfile, $filename ) . $suffix;
    }
    else {
        return Treex::PML::ResolvePath( $relfile, $filename );
    }
}

=item C<SetCurrentFileList($name)>

This macro is only available in TrEd. Selects the filelist of a given
name for the current window.

=cut

#ifdef TRED
sub SetCurrentFileList {
    my $name = shift;
    return if !TrEd::Macros::is_defined('TRED');
    croak("Usage: SelectFilelist(name)")
        if !defined($name)
            or ref($name)
            or !length($name);
    TrEd::ManageFilelists::selectFilelist( $grp, $name, @_ );
}

=item C<SetCurrentFileListInWindow($name, $win)>

This macro is only available in TrEd. Selects the filelist of a given
name for the given window.

=cut

sub SetCurrentFileListInWindow {
    my $name = shift;
    my $win  = shift;
    croak("Usage: SelectFilelistInWindow(name,win)")
        if !defined($name)
            or ref($name)
            or !length($name);
    return unless ref $win;
    TrEd::ManageFilelists::selectFilelist( $win, $name, @_ );
}

#endif

=item C<TrEdFileLists()>

This macro is only available in TrEd. It returns all registered
filelists.

=cut

#ifdef TRED
sub TrEdFileLists {
    return if !TrEd::Macros::is_defined('TRED');
    return TrEd::ManageFilelists::get_filelists();
}

#endif

=item C<GetFileSaveStatus()>

Return 1 if the document was modified since last save or reload, 0
otherwise.

=cut

sub GetFileSaveStatus {
    my $fsfile = CurrentFile();
    return $fsfile ? $fsfile->notSaved : 0;
}

=item C<SetFileSaveStatus()>

Use SetFileSaveStatus(1) to declare that some modification was made to
the file. Use SetFileSaveStatus(0) after the file was saved from a
macro (and TrEd/bTrEd would not notice that).

=cut

sub SetFileSaveStatus {
    my $fsfile = CurrentFile();
    $fsfile->notSaved( $_[0] ) if $fsfile;
}

=item C<DefaultInputEncoding()>

Return's TrEd's/bTrEd's default IO encoding.

=cut

sub DefaultInputEncoding {
    return $TrEd::Convert::inputenc;
}

=item C<SetDefaultInputEncoding(encoding)>

Set TrEd's/bTrEd's default IO encoding.

=cut

sub SetDefaultInputEncoding {
    $TrEd::Convert::inputenc = $_[0];
}

=item C<FileName()>

Return current file's name.

=cut

sub FileName {
    my $fsfile = CurrentFile();
    return $fsfile->filename if $fsfile;
}

=item C<FileMetaData(key,value?)>

Get or set meta data associated with the current L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>.  Key is the
meta data key. If value is omitted, current value associated with the
key is returned. Otherwise, the given value is associated with the
key, overwritting any previous value.

=cut

sub FileMetaData {
    my ( $name, $value ) = @_;
    if ( @_ <= 1 ) {
        CurrentFile()->metaData($name);
    }
    else {
        CurrentFile()->changeMetaData( $name, $value );
    }
}

=item C<FileUserData(key,value?)>

Get or set user data associated with the current L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>.  Key is the
user data key. If value is omitted, current value associated with the
key is returned. Otherwise, the given value is associated with the
key, overwritting any previous value.

=cut

sub FileUserData {
    my ( $name, $value ) = @_;
    my $fsfile = CurrentFile();
    unless ($fsfile) {
        confess("FileUserData: no file is open\n");
    }
    if ( @_ <= 1 ) {
        $fsfile->userData()->{$name};
    }
    else {
        $fsfile->userData()->{$name} = $value;
    }
}

=item C<FileAppData(key,value?)>

Get or set application specific data associated with the current
L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm>.  Key is the appData key. If value is omitted, current value
associated with the key is returned. Otherwise, the given value is
associated with the key, overwritting any previous value.

=cut

sub FileAppData {
    my ( $name, $value ) = @_;
    if ( @_ <= 1 ) {
        CurrentFile()->appData($name);
    }
    else {
        CurrentFile()->changeAppData( $name, $value );
    }
}

=item C<GotoFileNo(n)>

Goto n'th file in the current filelist.
The number of the first file in filelist is 0.

=cut

sub GotoFileNo {
    my $result;
    if ( $FileNotSaved ne '?' and $FileNotSaved ) {
        SetFileSaveStatus(1);
    }
    $result = TrEd::Filelist::Navigation::go_to_file( $grp, $_[0] );
    $root   = $grp->{root};
    $this   = $grp->{currentNode};
    return $result;
}

=item C<LastFileNo($win?)>

Return the index of the last file in the current filelist.

=cut

sub LastFileNo {
    shift if @_ and !ref( $_[0] );
    my $win = ref( $_[0] ) ? $_[0] : $grp;
    if ($win) {
        return $win->last_file_no();
    }
    return;
}

=item C<CurrentFileNo($win?)>

Return the index of the current file in the current filelist.

=cut

sub CurrentFileNo {
    shift if @_ and !ref( $_[0] );
    my $win = ref( $_[0] ) ? $_[0] : $grp;
    if ($win) {
        return $win->current_file_no();
    }
    return;
}

=item C<SaveAndNextFile()>

Save the current file and open the next file in the current file-list.

=cut

sub SaveAndNextFile {
    if ( GetFileSaveStatus() || $FileNotSaved ) {
        return unless Save();
    }
    NextFile();
}

=item C<NextFile()>

Goto next file in the file-list.

=cut

sub NextFile {
    my $result;
    if ( $FileNotSaved ne '?' and $FileNotSaved ) {
        SetFileSaveStatus(1);
    }
    if ( $result = TrEd::Filelist::Navigation::next_file($grp) ) {
        $root         = $grp->{root};
        $this         = $grp->{currentNode} || $root;
        $FileNotSaved = GetFileSaveStatus();
    }
    else {
        $FileNotSaved = 0 if $FileNotSaved eq '?';
    }
    return $result;
}

=item C<SaveAndPrevFile()>

Save the current file and open the previous file in the current
file-list.

=cut

sub SaveAndPrevFile {
    if ( GetFileSaveStatus() || $FileNotSaved ) {
        return unless Save();
    }
    PrevFile();
}

=item C<PrevFile()>

Goto previous file in the file-list.

=cut

sub PrevFile {
    my $result;
    if ( $FileNotSaved ne '?' and $FileNotSaved ) {
        SetFileSaveStatus(1);
    }
    if ( $result = TrEd::Filelist::Navigation::prev_file($grp) ) {
        $root         = $grp->{root};
        $this         = $grp->{currentNode} || $root;
        $FileNotSaved = GetFileSaveStatus();
    }
    else {
        $FileNotSaved = 0 if $FileNotSaved eq '?';
    }
    return $result;
}

=back

=head2 General I/O macros

=over 4

=item C<ResourcePaths()>

    Return the current list of directories used to search for
    resources.

=cut

*ResourcePaths = \&Treex::PML::ResourcePaths;

# old name:
*ResourcePath = \&Treex::PML::ResourcePaths;

=item C<SetResourcePaths(dirs)>

Set given list of directories as a current resource path (discarding
the existing values of ResourcePath).

=cut

*SetResourcePaths = \&Treex::PML::SetResourcePaths;

# old name
*SetResourcePath = \&Treex::PML::SetResourcePaths;

=item C<AddResourcePath(dirs)>

Add given directories to the end of the current resource path (to be
searched last).

=cut

*AddResourcePath = \&Treex::PML::AddResourcePath;

# old name
*AddToResourcePath = \&Treex::PML::AddResourcePath;

=item C<AddToResourcePathAsFirst(dirs)>

Add given directories to the beginning of the current resource path
(to be searched first).

=cut

*AddResourcePathAsFirst = \&Treex::PML::AddResourcePathAsFirst;

=item C<RemoveResourcePath(dir-paths)>

Remove given directories from the current resource path (directory
paths must exactly match those listed in the resource path).

=cut

*RemoveResourcePath = \Treex::PML::RemoveResourcePath;

#old name
*RemoveFromResourcePath = \Treex::PML::RemoveResourcePath;

=item C<FindDirInResources(dirname)>

If a given dirname is a relative path of a directory found in TrEd's
resource directory, return an absolute path for the
resource. Otherwise return dirname.

=cut

=item C<FindInResources(filename)>

If a given filename is a relative path of a file found in TrEd's
resource directory, return an absolute path for the
resource. Otherwise return filename.

=cut

=item C<ResolvePath(ref-filename,filename,use_resources?)>

If a given filename is a relative path, try to find the file in the
same directory as ref-filename. In case of success, return a path
based on the directory part of ref-filename and filename.  If the file
cannot be located in this way and use_resources is true, return the
value of C<FindInResources(filename)>.

=cut

=item C<SlurpURI($filename_or_uri,$chomp?)>

Given a file name or URI of a resource, the macro returns the content
of the resource. In array context the return value is a list of lines,
in scalar context the value is a scalar. If the chomp flag is true,
chomp() is applied to the returned array or scalar.

=cut

sub SlurpURI {
    my ( $filename, $encoding, $chomp ) = @_;
    my $fh = Treex::PML::IO::open_uri( $filename, $encoding );
    my $ret;
    my $wantarray = wantarray;
    if ($wantarray) {
        $ret = [<$fh>];
        chomp(@$ret) if $chomp;
    }
    else {
        local $/;
        $ret = <$fh>;
        chomp $ret if $chomp;
    }
    Treex::PML::IO::close_uri($fh);
    return $wantarray ? @$ret : $ret;
}

=item C<writeln(string?,...)>

Print the arguments to standard output appending a new-line if missing.

=cut

sub writeln { $::stdout->print( @_, $_[$#_] =~ /\n$/ ? () : "\n" ) }

=item C<stdout(string?,...)>

If called without arguments return current standard output filehandle.
Otherwise call print the arguments to standard output.

=cut

sub stdout { @_ ? $::stdout && $::stdout->print(@_) : $::stdout }

=item C<stderr(string?,...)>

If called without arguments return current standard error output
filehandle.  Otherwise call print the arguments to standard output.

=cut

sub stderr { @_ ? $::stderr && $::stderr->print(@_) : $::stderr }

=item C<tmpFileName()>

Returns a temporary filename..

=cut

sub tmpFileName {
    require POSIX;
    return POSIX::tmpnam();
}

=item C<DirPart($path)>

Returns directory part of a given path (including volume).

=cut

sub DirPart {
    return File::Spec->catpath( ( File::Spec->splitpath( $_[0] ) )[ 0, 1 ] );
}

=item C<FilePart($path)>

Returns file-name part of a given path.

=cut

sub FilePart {
    return ( ( File::Spec->splitpath( $_[0] ) )[2] );
}

=item C<CallerPath()>

Return path of the perl module or macro-file that invoked this macro.

=cut

sub CallerPath {
    return ( (caller)[1] );
}

=item C<CallerDir($rel_path?)>

If called without an argument, returns the directory of the perl
module or macro-file that invoked this macro.

If a relative path is given as an argument, a respective absolute path
is computed based on the caller's directory and returned.

=cut

sub CallerDir {
    return @_ > 0
        ? File::Spec->rel2abs( $_[0], DirPart( (caller)[1] ) )
        : DirPart( (caller)[1] );
}

=item C<FindMacroDir($rel_dir)>

Searches for a given relative path in directories with user-defined
macros and returns an absolute path to the first directory that matches.

=cut

sub FindMacroDir {
    my ($dir) = @_;
    confess("Usage: FindMacroDir(rel_dir)")
        unless defined $dir and length $dir;
    Encode::_utf8_off($dir);    # make sure it does not carry an UTF8 flag!
    for my $macro_dir ( $libDir, @TrEd::Macros::macro_include_paths ) {
        my $candidate = File::Spec->catdir( $macro_dir, 'contrib', $dir );
        if ( -d $candidate ) {
            return $candidate;
        }
    }
    confess(
        "FindMacroDir: didn't find subdirectory '$dir' in macro paths: $libDir @TrEd::Macros::macro_include_paths\n"
    );
}

=back

=cut

#######################################################

=head2 Printing trees

=over 4

=item C<PrintDialog(-option =E<gt> value,...)>

Display TrEd's standard print dialog. Possible options providing
substitutes for the default values in the print dialog are:

=over 3

=item C<-command>

System command to send the output to (e.g. C<lpr> to print on the
default printer on UNIX platform).

=item C<-toFile>

If set to 1, the output is saved to a file specified in C<-filename>.

=item C<-filename>

Output filename.

=item C<-fileExtension>

Default output file extension.

=item C<-format>

One of PS, PDF, EPS, ImageMagick. Default is PS.

=item C<-imageMagickResolution>

This value is passed to the command C<convert> of the ImageMagick
toolkit as C<-density>. It specifies the horizontal and vertical
resolution in pixels of the image.

=item C<-noRotate>

Disable automatic landscape rotation of trees which are wider than
taller.

=item C<-sentenceInfo>

If set to 1, this command prints also the text associated with the
tree. Instead of 0 or 1, an CODE reference (subroutine) may be passed
in this parameter. This CODE is then evaluated for every tree to
produce the desired text. The CODE obtains two arguments: the current
L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object and an integer position of the tree (starting from 0).

=item C<-fileInfo>

If true, print filename and tree number under each tree.

=item C<-colors>

Set to 1 for colour output.

=back

=cut

sub PrintDialog {
    my (%opts) = @_;
    if ( GUI() ) {
        local $main::insideEval   = 0;
        local $grp->{currentNode} = $this;
        local $grp->{root}        = $root;

        foreach (
            qw(-command -filename -psFile -toFile -format -noRotate -sentenceInfo
            -imageMagickResolution -fileExtension -fileInfo -colors)
            )
        {
            if ( exists( $opts{$_} ) ) {
                my $o = $_;
                $o =~ s/^-//;
                $o = 'psFile' if $o eq 'filename';
                $grp->{framegroup}->{ "print" . ucfirst($o) } = $opts{$_};
            }
            main::printThis( $grp->{framegroup} );
        }
    }
    else {
        die "Cannot call PrintDialog from non-GUI version TrEd\n";
    }
    return 1;
}

=item C<Print(-option =E<gt> value,...)>

Print trees given from current file according to given printing options:

=over 3

=item C<-range>

Lists trees to be printed (e.g. C<5,-3,9-12,15-> prints trees
5,1,2,3,9,10,11,12,15,16,...)

=item C<-to>

Possible values: file (print to file specified by C<-filename>),
(send output to ImageMagick convert, see C<-convert>),
pipe (send output to the standard input of command C<-command>),
string (return output as a string), object (return output as an object -
the exact type of the value depends on the output format).

=item C<-command>

System command to send the output to (usually default to C<lpr> on UNIX platform).

=item C<-convert>

Path to ImageMagick 'convert' command.

=item C<-filename>

Output filename (only when printing to file).

=item C<-format>

One of PS, PDF, EPS, ImageMagick. Default is PS.

=item C<-noRotate>

Disable automatic landscape rotation of trees which are wider than
taller.

=item C<-sentenceInfo>

If set to 1, this command prints also the text associated with the
tree. Instead of 0 or 1, a CODE reference (subroutine) may be passed
in this parameter. This CODE is then evaluated for every tree to
produce the desired text. The CODE obtains two arguments: the current
L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object and an integer position of the tree (starting from 0).

=item C<-fileInfo>

If true, print filename and tree number under each tree.

=item C<-imageMagickResolution>

This value is passed to the command C<convert> of the ImageMagick
toolkit as C<-density>. It specifies the horizontal and vertical
resolution in pixels of the image.

=item C<-colors>

Set to 1 for colour output.

=item C<-hidden>

Set to 1 to print hidden nodes.

=item C<-psFontFile>

Specifies the PostScript font file to be used instead of the default
one.

=item C<--psFontAFMFile>

Specifies the PostScript ASCII metric font file to be used instead of
the default one.

=item C<-ttFont>

Specifies the TrueType font file to be used when printing via PDF.

=item C<-fontSize>

Font size.

=item C<-fmtWidth>

Page width.

=item  C<-fmtHeight>

Page height.

=item C<-hMargin>

The size of the left and right horizontal margins.

=item C<-vMargin>

The size of the top and bottom margins.

=item C<-maximize>

Expand small trees to fit the whole page size. (Shrinking is done
automatically).

=item C<-psMedia>

Specifies target given media size (used for PostScript and PDF).
Possible values:

User (dimensions specified in -fmtHeight and -fmtWidth), BBox
(bounding box of the tree with only -hMargin and -vMargin added),
Letter, LetterSmall, Legal, Statement, Tabloid, Ledger, Folio, Quarto,
Executive, A0, A1, A2, A3, A4, A4Small, A5, A6, A7, A8, A9, A10, B0,
B1, B2, B3, B4, B5, B6, B7, B8, B9, B10, ISOB0, ISOB1, ISOB2, ISOB3,
ISOB4, ISOB5, ISOB6, ISOB7, ISOB8, ISOB9, ISOB10, C0, C1, C2, C3, C4,
C5, C6, C7, 7x9, 9x11, 9x12, 10x13, 10x14

=item C<-stylesheet>

Name of the stylesheet to use (defaults to the current stylesheet).

=item C<-toplevel>

Toplevel window (e.g. ToplevelFrame()) if you wish for graphical progress
indicator.

=back

=cut

sub Print {
    my (%opts) = @_;

    if ( GUI() ) {
        my $gui = $grp->{framegroup};
        local $main::insideEval   = 0;
        local $grp->{currentNode} = $this;
        local $grp->{root}        = $root;
        local $grp->{treeNo}      = $grp->{treeNo};
        local $grp->{Nodes}       = $grp->{Nodes};

        $opts{-range} = CurrentTreeNumber() + 1
            unless defined( $opts{-range} )
                and length( $opts{-range} );
        foreach (
            qw(command toFile format noRotate sentenceInfo
            imageMagickResolution colors)
            )
        {
            unless ( exists( $opts{"-$_"} ) ) {
                $opts{"-$_"} = $gui->{ "print" . ucfirst($_) };
            }
        }

        # apply default options
        my $def = $TrEd::Config::printOptions;
        if ($def) {
            foreach my $opt ( keys %$def ) {
                my $name = $TrEd::Config::defaultPrintConfig{$opt}[0];
                if (    $name
                    and !exists( $opts{$name} )
                    and exists( $def->{$opt} ) )
                {
                    $opts{$name} = $def->{$opt};
                }
            }
        }
        else {
            $def = {};
        }

        if ( $opts{-format} eq 'PDF' and !$opts{-ttFont} ) {
            $gui->{ttfonts} ||= TrEd::Print::get_ttf_fonts(
                { try_fontconfig => 1 },
                map { TrEd::Config::tilde_expand($_) } split /,/,
                $def->{ttFontPath}
            );
            my $fn = delete( $opts{ttFontName} )
                || $TrEd::Config::printOptions->{ttFont};
            $opts{ttFont} = $gui->{ttfonts}->{$fn};
        }
        if ( !$opts{-styleSheetObject} ) {
            my $stylesheet = $opts{-stylesheet} || $grp->{stylesheet};
            if ( $stylesheet ne STYLESHEET_FROM_FILE() ) {
                $opts{-styleSheetObject} = $gui->{stylesheets}->{$stylesheet};
            }
        }
        $opts{-treeViewOpts} ||= $TrEd::Config::treeViewOpts;
        $opts{-toplevel} = ToplevelFrame() unless exists $opts{-toplevel};
        $opts{-fsfile}  ||= CurrentFile();
        $opts{-convert} ||= $TrEd::Config::imageMagickConvert;
        return TrEd::Print::Print(
            {   -context        => $grp,
                -onGetRootStyle => \&main::onGetRootStyle,
                -onGetNodeStyle => \&main::onGetNodeStyle,
                -onRedrawDone   => \&main::onRedrawDone,
                -onGetNodes     => \&main::printGetNodesCallback,
                %opts,
            }
        );
    }
    else {
        die "Cannot call PrintDialog from non-GUI version TrEd\n";
    }
}

=back

=cut

##########################################

=head2 Other macros

=over 4

=item C<quit()>

This command acts just like a C<die> but without producing any error
message at all. It can be used to immediatelly stop execution of the
macro code and returning control to TrEd or btred (in which case btred
starts processing the next file) but does not propagate through
C<eval{}>, so it can also be trapped.

Note that hooks that my follow execution of the macro code (such as
file_close_hook or exit_hook in btred) are executed as if the macro
ended normally.

=cut

{

    package TredMacro::Error;

    # A simple class for reporting structured errors, currently only used by
    # quit() to silently die.
    # In general, it can be used to pass data to the outer context.

    use overload q{""} => sub { shift->message };
    sub new { my $class = shift; bless [@_], $class }
    sub message { q{} . shift->[0] }
    sub throw {
        my $self = shift;
        ref($self) ? die $self : die $self->new(@_);
    }

}

sub quit {
    TredMacro::Error->throw(q{});
}

=back

=cut

##########################################

=head2 Implementation of TredMacro::import

=over 4

=item C<import(names?)>

If specified without parameter, exports every symbol to the caller
package (except for symbols already (re)defined in the caller
package). If parameters are given, exports only names specified by
the parameters and the following few variables that every package
derived from TredMacro (e.g. a context)  B<must> share: C<$libDir>,
C<$grp>, C<$root>, C<$this> C<$_NoSuchTree> C<$Redraw>,
C<$forceFileSaved>, C<$FileChanged>, C<$FileNotSaved>,
C<$NodeClipboard>.

=cut

sub _import {

    # If specified without parameter, exports everything but
    # names already defined in caller package
    # If parameters are given, exports only names specified by the parameters
    # and few variables that every TredMacro *must* share.

    no strict qw(refs);
    my $pkg    = shift;
    my $caller = shift;
    my $type;
    my @exports = @_;

    #  use Data::Dumper;
    #  print Dumper(\@exports);
    foreach my $k (@exports) {
        next if $k =~ /::$/;    # do not export packages themselves
        unless ( $k =~ s/^(\W)// ) {
            *{"${caller}::$k"} = \&{"${pkg}::$k"}
                unless exists( &{"${caller}::$k"} );
            next;
        }
        $type = $1;
        if ( $type eq '&' ) {
            *{"${caller}::$k"} = \&{"${pkg}::$k"};
        }
        elsif ( $type eq '$' ) {
            *{"${caller}::$k"} = \${"${pkg}::$k"};
        }
        elsif ( $type eq '@' ) {
            *{"${caller}::$k"} = \@{"${pkg}::$k"};
        }
        elsif ( $type eq '%' ) {
            *{"${caller}::$k"} = \%{"${pkg}::$k"};
        }
        elsif ( $type eq '*' ) {
            *{"${caller}::$k"} = \*{"${pkg}::$k"};
        }
        else {

            #      do { warn("Cannot export symbol: $type $pkg $k") };
        }
    }
}

sub import {

    # If specified without parameter, exports everything but
    # names already defined in caller package
    # If parameters are given, exports only names specified by the parameters
    # and few variables that every TredMacro *must* share.
    no strict qw(refs);
    my $pkg = shift;

     #print "TredMacro imported from " . caller() ."\n";
    _import( $pkg, scalar(caller),
        ( $#_ >= 0 ? @_ : grep { $_ ne 'BEGIN' } keys %{"${pkg}::"} ),
        @FORCE_EXPORT,
        @EXPORT );
}

sub import_only {

    # exports only names specified by the parameters
    _import( shift, scalar(caller), @_ );
}

=back

=cut

############################################

=head2 XPath extension (slow)

=over 4

=item C<SetupXPath(function-mapping...)>

C<SetupXPath(
            id         =E<gt> \&find_node_by_id,
            pos        =E<gt> \&node_position,
            attributes =E<gt> \&node_attributes_hashref,
            name       =E<gt> \&node_name,
            value      =E<gt> \&node_value,
            children   =E<gt> \&node_children,
            parent     =E<gt> \&node_parent,
            lbrother   =E<gt> \&node_left_sibling,
            rbrother   =E<gt> \&node_right_sibling,
           )>

This macro requires C<XML::XPath> module to be installed.  It adjusts
L<Treex::PML::Node|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Node.pm> API to match XPath model based on a given function mapping.  By
default, 'id' is defined to return nothing, 'pos' returns nodes
sentence-ordering position (or depth-first-ordering position if sentord
attribute is not defined), 'attributes' returs a hashref of node's
attributes (actually a L<Treex::PML::Node|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Node.pm> itself), 'name' returns "node", 'value'
returns node's value of the special FS value attribute, and
'children', 'parent', 'lbrother', and 'rbrother' all default to the
respective L<Treex::PML::Node|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Node.pm> methods.

Usage example:

C<SetupXPath(id    =E<gt> sub { $hashed_ids{ $_[0] } },
           name  =E<gt> sub { $_[0]-E<gt>{functor} }
           value =E<gt> sub { $_[0]-E<gt>{t_lemma} });>

C<foreach ($node-E<gt>findnodes(q{//ACT/PAT[starts-with(@tag,"N") or .="ano"]})) {
    # process matching nodes
}>

=cut

sub SetupXPath {
    my %handlers = @_;

    unless ( exists $handlers{pos} ) {
        my $attr = FS()->sentord() || FS()->order();
        $handlers{pos} = sub { $_[0]->{$attr} };
    }
    unless ( exists $handlers{value} ) {
        my $val = FS()->value();
        $handlers{value} = sub { $_[0]->{$val} };
    }

    *Treex::PML::Node::getElementById = $handlers{id}  if $handlers{id};
    *Treex::PML::Node::get_global_pos = $handlers{pos} if $handlers{pos};
    *Treex::PML::Node::getAttributes = $handlers{attributes}
        if $handlers{attributes};
    *Treex::PML::Node::getName      = $handlers{name}  if $handlers{name};
    *Treex::PML::Node::getLocalName = $handlers{name}  if $handlers{name};
    *Treex::PML::Node::getValue     = $handlers{value} if $handlers{value};
    *Treex::PML::Node::string_value = $handlers{value} if $handlers{value};

    *Treex::PML::Node::getParentNode = $handlers{parent} if $handlers{parent};
    *Treex::PML::Node::getChildNodes = $handlers{children}
        if $handlers{children};
    *Treex::PML::Node::getPreviousSibling = $handlers{lbrother}
        if $handlers{lbrother};
    *Treex::PML::Node::getNextSibling = $handlers{rbrother}
        if $handlers{rbrother};
}

sub noop {1}

##############################
# Toolbars

#ifdef TRED
sub NewUserToolbar {
    my ( $name, $opts ) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    my $user_toolbar = TrEd::Toolbar::User::Manager::create_new_user_toolbar(
        $grp->{framegroup}, $name, $opts );
    return $user_toolbar->get_user_toolbar() if defined $user_toolbar;
    return;
}

sub GetUserToolbar {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    my $user_toolbar = TrEd::Toolbar::User::Manager::get_user_toolbar($name);
    return $user_toolbar->get_user_toolbar() if defined $user_toolbar;
    return;

}

sub RemoveUserToolbar {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    return TrEd::Toolbar::User::Manager::destroy_user_toolbar(
        $grp->{framegroup}, $name );
}

sub DestroyUserToolbar {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    my $tb = TrEd::Toolbar::User::Manager::destroy_user_toolbar(
        $grp->{framegroup}, $name );
    $tb->destroy if $tb;
    return;
}

sub HideUserToolbar {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    my $user_toolbar = TrEd::Toolbar::User::Manager::get_user_toolbar($name);
    return $user_toolbar->hide() if defined $user_toolbar;
    return;
}

sub ShowUserToolbar {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    my $user_toolbar = TrEd::Toolbar::User::Manager::get_user_toolbar($name);
    return $user_toolbar->show() if defined $user_toolbar;
    return;
}

sub EnableUserToolbar {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    my $tb = GetUserToolbar($name);
    if ($tb) {
        for my $w ( main::get_widget_descendants($tb) ) {
            eval { $w->configure( -state => 'normal' ) };
        }
        return $tb;
    }
    return 0;
}

sub DisableUserToolbar {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    my $tb = GetUserToolbar($name);
    if ($tb) {
        for my $w ( main::get_widget_descendants($tb) ) {
            eval { $w->configure( -state => 'disabled' ) };
        }
        return $tb;
    }
    return 0;
}

sub UserToolbarVisible {
    my ($name) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    my $user_toolbar = TrEd::Toolbar::User::Manager::get_user_toolbar($name);
    return $user_toolbar->visible();
}

sub AttachTooltip {
    my ( $widget, $message ) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    $grp->{framegroup}{Balloon}->attach( $widget, -balloonmsg => $message );
}

#endif

##################################
# MinorModes

sub DeclareMinorMode {

    #ifdef TRED
    my ( $name, $opts ) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    croak "The 1st argument to DeclareMinorMode must be a context name!"
        unless ( defined($name) and length($name) and !ref($name) );
    croak "The 2nd argument to DeclareMinorMode must be a hash reference!"
        unless ref($opts) eq 'HASH';

#  croak "Too soon to call  DeclareMinorMode" unless ref($grp) and ref($grp->{framegroup});
    TrEd::MinorModes::declare_minor_mode( $grp, $name, $opts );

    #endif
}

sub EnableMinorMode {

    #ifdef TRED
    my ( $name, $win ) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    TrEd::MinorModes::enable_minor_mode( $win || $grp, $name );

    #endif
}

sub DisableMinorMode {

    #ifdef TRED
    my ( $name, $win ) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    TrEd::MinorModes::disable_minor_mode( $win || $grp, $name );

    #endif
}

sub ListEnabledMinorModes {

    #ifdef TRED
    my ($win) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    $win ||= $grp;
    return ref( $win->{minorModes} ) ? @{ $win->{minorModes} } : ();

    #endif
}

sub IsMinorModeEnabled {

    #ifdef TRED
    my ( $name, $win ) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    $win ||= $grp;
    return 0 unless ref( $win->{minorModes} );
    for my $c ( @{ $win->{minorModes} } ) {
        return 1 if $c eq $name;
    }
    return 0;

    #endif
}

sub SetMinorModeData {

    #ifdef TRED
    my ( $name, $key, $value, $win ) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    $win ||= $grp;
    return $win->{minorModeData}{$name}{$key} = $value;

    #endif
}

sub GetMinorModeData {

    #ifdef TRED
    my ( $name, $key, $win ) = @_;
    return if !TrEd::Macros::is_defined('TRED');
    $win ||= $grp;
    return $win->{minorModeData}{$name}{$key};

    #endif
}

=back

=cut

1;
