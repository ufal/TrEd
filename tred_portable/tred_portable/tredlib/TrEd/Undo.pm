package TrEd::Undo;

use strict;
use warnings;

use Carp;

use TrEd::Config qw{$tredDebug $maxUndo};
use TrEd::Utils qw{uniq $EMPTY_STR};
use TrEd::Error::Message;
use Data::Snapshot;
use TrEd::File;

use Readonly;

Readonly my %UNDO_TYPE => (
    UNDO_ACTIVE_NODE                 => 1,
    UNDO_ACTIVE_ROOT                 => 2,
    UNDO_DATA_AND_TREE_ORDER         => 3,
    UNDO_TREE_ORDER                  => 4,
    UNDO_DISPLAYED_TREES             => 5,
    UNDO_CURRENT_TREE_AND_TREE_ORDER => 6,
    UNDO_ACTIVE_ROOT_AND_TREE_ORDER  => 7,
    UNDO_DATA                        => 8,
    UNDO_CURRENT_TREE                => 9,
);

sub undo_type_id {
    my ($undo_type) = @_;
    if ( exists $UNDO_TYPE{$undo_type} ) {
        return $UNDO_TYPE{$undo_type};
    }
    else {
        croak('Unknown undo type');
    }
}

#######################################################################################
# Usage         : prepare_undo($win, $message, $what, $data)
# Purpose       : Prepare undo stack data of type $what for window $win
# Returns       : Undo stack frame
# Parameters    : TrEd::Window ref $win -- ref to focused window
#                 string $message     -- message to be stored inside the undo frame
#                 scalar $what    -- type of undo operation, see %UNDO_TYPE
#                 anything $data -- data to be stored in the undo frame
# Throws        : no exception
# Comments      : The undo stack frame is a reference to array with two elements:
#                 first one is a ref to currently active Treex::PML::Document object,
#                 second one is a reference to array.
#                 this array contains 6 elements:
#                   0. 'Snapshot' string
#                   1. number of current tree in focused window
#                   2. snapshot created by Data::Snapshot package
#                   3. reference to current node in focused window
#                   4. message from $message argument
#                   5. type of undo operation
# See Also      : bind_key(), get_binding_for_key(), get_bindings_for_macro()
sub prepare_undo {
    my ( $win, $message, $what, $data ) = @_;
    return if !$TrEd::Config::maxUndo;
    my $fsfile = $win->{FSFile};
    return if !defined $fsfile;

    $what ||= $UNDO_TYPE{UNDO_DISPLAYED_TREES};
    my $snapshot;
    if ( $what == $UNDO_TYPE{UNDO_ACTIVE_NODE} ) {
        $data = $win->{currentNode};
    }
    elsif ( $what == $UNDO_TYPE{UNDO_ACTIVE_ROOT} ) {
        $data = $win->{currentNode};
        return if not ref $data;
        $data = $data->root;
    }
    elsif ( $what == $UNDO_TYPE{UNDO_CURRENT_TREE} ) {
        return if !ref( $win->{root} );
        $data = $win->{root};
    }
    elsif ( $what == $UNDO_TYPE{UNDO_TREE_ORDER} ) {
        $snapshot = [ @{ $fsfile->treeList } ];
    }
    elsif ( $what == $UNDO_TYPE{UNDO_DISPLAYED_TREES} ) {
        my $n = $win->{Nodes} || [];
        my %n;
        @n{ @{$n} } = ();

        # the following should be a bit faster than uniq map $_->root, @$n
        $data = [
            uniq map {
                my $p = $_->parent;
                $p && exists( $n{$p} ) ? () : ( $p ? $p->root : $_ )
                } @{$n}
        ];
    }
    elsif ( $what == $UNDO_TYPE{UNDO_DATA_AND_TREE_ORDER} ) {
        if ( ref $data ) {
            $snapshot = [
                Data::Snapshot::make_data_snapshot($data),
                [ @{ $fsfile->treeList } ]
            ];
        }
        else {
            $what     = $UNDO_TYPE{UNDO_TREE_ORDER};
            $snapshot = [ @{ $fsfile->treeList } ];
        }
    }
    elsif ( $what == $UNDO_TYPE{UNDO_CURRENT_TREE_AND_TREE_ORDER} ) {
        return if not ref $win->{root};
        $snapshot = [
            Data::Snapshot::make_data_snapshot( $win->{root} ),
            [ @{ $fsfile->treeList } ]
        ];
    }
    elsif ( $what == $UNDO_TYPE{UNDO_ACTIVE_ROOT_AND_TREE_ORDER} ) {
        my $n = $win->{currentNode};
        return if not ref $n;
        $snapshot = [
            Data::Snapshot::make_data_snapshot( $n->root ),
            [ @{ $fsfile->treeList } ]
        ];
    }
    elsif ( $what == $UNDO_TYPE{UNDO_DATA} ) {
        # $data = $data;
    }
    else {
        TrEd::Error::Message::error_message( $win,
            "Unknown undo type: $what\n" );
        return;
    }
    if ( not defined $snapshot ) {
        return if not ref $data;
        $snapshot = [ Data::Snapshot::make_data_snapshot($data), $data ];
    }
    return [
        $fsfile,
        [   'Snapshot',          $win->{treeNo}, $snapshot,
            $win->{currentNode}, $message,       $what
        ]
    ];
}

# redo
sub prepare_redo {
    my ( $win, $undo ) = @_;
    my $type    = $undo->[0];
    my $message = $undo->[4];
    return prepare_undo( $win, $message ) if $type ne 'Snapshot';
    my $what     = $undo->[5];
    my $snapshot = $undo->[2];
    $what ||= $UNDO_TYPE{UNDO_DISPLAYED_TREES};
    if (   $what == $UNDO_TYPE{UNDO_ACTIVE_NODE}
        or $what == $UNDO_TYPE{UNDO_ACTIVE_ROOT}
        or $what == $UNDO_TYPE{UNDO_DATA}
        or $what == $UNDO_TYPE{UNDO_CURRENT_TREE}
        or $what == $UNDO_TYPE{UNDO_DISPLAYED_TREES} )
    {
        return prepare_undo( $win, $message, $UNDO_TYPE{UNDO_DATA},
            $snapshot->[1] );
    }
    elsif ( $what == $UNDO_TYPE{UNDO_TREE_ORDER} ) {
        return prepare_undo( $win, $message, $UNDO_TYPE{UNDO_TREE_ORDER} );
    }
    elsif ($what == $UNDO_TYPE{UNDO_CURRENT_TREE_AND_TREE_ORDER}
        or $what == $UNDO_TYPE{UNDO_ACTIVE_ROOT_AND_TREE_ORDER}
        or $what == $UNDO_TYPE{UNDO_DATA_AND_TREE_ORDER} )
    {
        return prepare_undo( $win, $message,
            $UNDO_TYPE{UNDO_DATA_AND_TREE_ORDER},
            $snapshot->[1] );
    }
    else {
        TrEd::Error::Message::error_message( $win,
            "Unknown undo type: $what\n" );

        return prepare_undo( $win, $message );
    }
}

# undo
sub save_undo {
    my ( $win, $undo ) = @_;
    return if not $maxUndo;
    return if not ref $undo;
    my $fsfile = $undo->[0];
    $undo = $undo->[1];
    return if not (ref $fsfile and ref $undo);
    if ($tredDebug) {
        print "Saving undo: $undo->[4] for file " . $fsfile->filename() . "\n";
    }

    if ( $fsfile != $win->{FSFile} ) {
        warn(
            "Undo: window displays a different file than undo was prepared for.\n"
        );
    }

    TrEd::File::init_app_data($fsfile);

    my $stack = $fsfile->appData('undostack');
    splice @{$stack}, $fsfile->appData('undo') + 1;    # remove redo
    push @{$stack}, $undo;
    if ( $maxUndo > 0 and @{$stack} > $maxUndo ) {
        splice @{$stack}, 0, ( @{$stack} - $maxUndo );
        print STDERR 'Undo-stack: overflow, removing ',
            ( @{$stack} - $maxUndo ), " items\n"
            if $tredDebug;
    }
    $fsfile->changeAppData( 'undo', $#$stack );
    reset_undo_status($win);
    print STDERR "Undo-stack: $#{$stack} items\n" if $tredDebug;
}

# redo
sub re_do {
    my ($grp_or_win) = @_;
    my $win = main::cast_to_win($grp_or_win);
    return if not $maxUndo;
    my $fsfile = $win->{FSFile};
    return if not $fsfile;
    my $stack = $fsfile->appData('undostack');
    return unless ( @{$stack} > $fsfile->appData('undo') + 2 );
    if ($tredDebug) {
        print STDERR 'Redo: ', $fsfile->appData('undo') + 2, "/$#{$stack}\n";
    }
    $fsfile->changeAppData( 'undo', $fsfile->appData('undo') + 2 );
    return undo( $win, 1 );
}

# undo
sub undo {
    my ( $grp_or_win, $redo ) = @_;
    my $win = main::cast_to_win($grp_or_win);
    return if not $maxUndo;
    my $fsfile = $win->{FSFile};
    return if not $fsfile;
    my $stack    = $fsfile->appData('undostack');
    my $stackpos = $fsfile->appData('undo');
    return
        unless ( ref $stack
        and ( @{$stack} > 0 )
        and ( $stackpos >= 0 )
        and ( $stackpos <= $#{$stack} ) );
    my $undo = $stack->[$stackpos];

    if ($undo) {
        my $new_undo;
        my $type = $undo->[0];
        if ( !$redo && $#{$stack} == $stackpos ) {
            $new_undo = prepare_redo( $win, $undo );
        }
        my $treeNo   = $undo->[1];
        my $snapshot = $undo->[2];
        if ( $type eq 'Snapshot' ) {
            my $what = $undo->[5];
            if (   $what == $UNDO_TYPE{UNDO_ACTIVE_NODE}
                or $what == $UNDO_TYPE{UNDO_ACTIVE_ROOT}
                or $what == $UNDO_TYPE{UNDO_DISPLAYED_TREES}
                or $what == $UNDO_TYPE{UNDO_DATA} )
            {
                Data::Snapshot::restore_data_from_snapshot( $snapshot->[0] );
                # nothing to do
            }
            elsif ( $what == $UNDO_TYPE{UNDO_CURRENT_TREE} ) {
                my $prev = $fsfile->treeList->[$treeNo];
                if (ref $prev) {
                    $prev->destroy();
                }
                $fsfile->treeList->[$treeNo]
                    = Data::Snapshot::restore_data_from_snapshot(
                    $snapshot->[0] );
            }
            elsif ( $what == $UNDO_TYPE{UNDO_TREE_ORDER} ) {
                @{ $fsfile->treeList } = @{$snapshot};
            }
            # this code does the same thing as the next branch, but since it 
            # contains some code that is commented out, maybe it will be 
            # useful in the future, if it has to be restored
#            elsif ( $what == $UNDO_TYPE{UNDO_CURRENT_TREE_AND_TREE_ORDER} ) {
#                # my $prev = $fsfile->treeList->[$treeNo];
#                # $prev->destroy if ref($prev);
#                # $prev=
#                Data::Snapshot::restore_data_from_snapshot( $snapshot->[0] );
#                my %r;
#                @r{ @{ $snapshot->[1] } } = ();
#                for ( @{ $fsfile->treeList } ) {
#                    if (
#                        eval { ref $_ && !$_->parent && !exists( $r{$_} ) }
#                        ) 
#                    {
#                        $_->destroy();
#                    }
#                }
#                @{ $fsfile->treeList } = @{ $snapshot->[1] };
#
#                # $fsfile->treeList->[$treeNo]=$prev;
#            }
            elsif ($what == $UNDO_TYPE{UNDO_ACTIVE_ROOT_AND_TREE_ORDER}
                or $what == $UNDO_TYPE{UNDO_DATA_AND_TREE_ORDER}
                or $what == $UNDO_TYPE{UNDO_CURRENT_TREE_AND_TREE_ORDER})
            {
                Data::Snapshot::restore_data_from_snapshot( $snapshot->[0] );
                my %r;
                @r{ @{ $snapshot->[1] } } = ();
                for ( @{ $fsfile->treeList } ) {
                    if (
                        eval { ref $_ && !$_->parent && !exists( $r{$_} ) }
                        )
                    {
                        $_->destroy;
                    }
                }
                @{ $fsfile->treeList } = @{ $snapshot->[1] };
            }
            else {
                TrEd::Error::Message::error_message( $win,
                    "Unknown undo type: $what\n" );
            }
        }
        elsif ( $type eq 'FS' ) {
            my $prev = $fsfile->treeList->[$treeNo];
            if (ref $prev) {
                $prev->destroy;
            }
            $fsfile->treeList->[$treeNo]
                = $fsfile->FS->parseFSTree($snapshot);
        }
        elsif ( $type eq 'Storable' ) {
            my $prev = $fsfile->treeList->[$treeNo];
            if (ref $prev) {
                $prev->destroy();
            }
            $fsfile->treeList->[$treeNo] = Storable::thaw($snapshot);
        }
        if ( $#{$stack} == $stackpos ) {
            if ($redo) {
                pop @{$stack};
            }
            else {
                push @{$stack}, $new_undo->[1];
            }
        }
        if ($tredDebug) {
            print STDERR 'Undo: ', $stackpos . "/$#$stack\n";
        }
        $fsfile->changeAppData( 'undo', $fsfile->appData('undo') - 1 );
        reset_undo_status($win);
        $fsfile->notSaved(1);
        $win->{treeNo} = $treeNo;
        main::get_nodes_fsfile_tree( $win->{framegroup}, $fsfile, $treeNo );
        $win->{currentNode}
            = ref $undo->[3] ? $undo->[3] : $win->{Nodes}[ $undo->[3] ];
        $win->ensure_current_is_displayed();
        main::redraw_fsfile_tree( $win->{framegroup}, $fsfile, $treeNo );
        main::centerTo( $win, $win->{currentNode} );
    }
    else {
        TrEd::Error::Message::error_message( $win, 'Corrupted undo stack!' );
    }
    return;
}

# undo
sub reset_undo_status {
    my ($win)  = @_;
    my $fsfile = $win->{FSFile};
    my $grp    = $win->{framegroup};
    my ( $undostatus, $redostatus );
    my $undomessage = $EMPTY_STR;
    my $redomessage = $EMPTY_STR;

    if ( $maxUndo != 0 and ref $fsfile ) {
        my $stack    = $fsfile->appData('undostack');
        my $stackpos = $fsfile->appData('undo');
        if ($tredDebug) {
            print STDERR "UNDO_STACK: $stackpos/", $#{$stack} + 1, "\n";
        }
        $undostatus = ( ref $stack && ( @{$stack} > 0 ) );
        $redostatus = ( $undostatus && ( @{$stack} > $stackpos + 2 ) );
        $undostatus &&= ( ( $stackpos >= 0 ) && ( $stackpos <= $#{$stack} ) );
        if ($undostatus) {
            $undomessage = ': ' . $stack->[$stackpos]->[4];
        }
        if ($redostatus) {
            $redomessage = ': ' . $stack->[ $stackpos + 1 ]->[4];
        }
    }
    else {
        $undostatus = 0;
        $redostatus = 0;
    }
    if ( $grp->{undoButton} ) {
        $grp->{undoButton}
            ->configure( -state => ( $undostatus ? 'normal' : 'disabled' ) );
        $grp->{Balloon}->attach( $grp->{undoButton},
            -balloonmsg => 'Undo' . $undomessage );
    }
    if ( $grp->{redoButton} ) {
        $grp->{redoButton}
            ->configure( -state => ( $redostatus ? 'normal' : 'disabled' ) );
        $grp->{Balloon}->attach( $grp->{redoButton},
            -balloonmsg => 'Redo' . $redomessage );
    }
    return;
}

1;

