package TrEd::Dialog::EditAttributes;

use strict;
use warnings;

use Carp;
use TrEd::Utils qw{$EMPTY_STR};
use TrEd::Config
    qw{$sortAttrs $sortAttrValues $sidePanelWrap $font $maxDisplayedAttributes};
use TrEd::MinMax qw{max2 min};

use Treex::PML::Schema;

require TrEd::Undo;
require TrEd::Bookmarks;

# was main::editAttrsDialog_schema
sub dialog_schema {
    my ( $win, $node, $attr_path, $as_type, $focus ) = @_;
    my $grp = $win->{framegroup};
    my $base_type
        = ref($as_type) ? $as_type : main::determineNodeType( $win, $node );
    return unless $base_type;
    my $schema;
    my $enabled = 1;
    my $node_type;

    $win->toplevel->Busy( -recurse => 1 );
    if ( $attr_path ne $EMPTY_STR ) {
        $node_type = $base_type->find( $attr_path, 1 );
        croak("Unknown attribute $attr_path") unless $node_type;
        $enabled = 0
            if (main::doEvalHook( $win, 'enable_attr_hook', $attr_path,
                                  "normal", $node )
                // q()) eq 'stop';
    }
    else {
        $enabled = 0
            if ( main::doEvalHook( $win, 'enable_edit_node_hook', $node ) eq
            'stop' );
        $node_type = $base_type;
    }

    my $dlg_title
        = $attr_path ne $EMPTY_STR
        ? "Edit Attribute '$attr_path'"
        : "Edit Node";
    my $result = $win->toplevel->TrEdNodeEditDlg(
        {   title   => $dlg_title,
            type    => $base_type,
            object  => $node,
            path    => $attr_path,
            focus   => ( defined $focus ? $focus : $attr_path ),
            buttons => [
                $enabled
                ? ( $attr_path ? qw(OK Cancel) : qw(OK Help Cancel) )
                : ('Cancel')
            ],
            no_sort           => !$sortAttrs,
            no_value_sort     => !$sortAttrValues,
            side_panel_wrap   => $sidePanelWrap,
            buttons_configure => {
                Help => [
                    -command => [
                        sub {
                            main::help_topic( shift,
                                'new_editnode_interface' );
                            Tk->break;
                            }
                    ]
                ]
            },
            enable_callback => [
                sub {
                    my ( $win, $base_path, $node, $path ) = @_;
                    my $enable_attr
                        = main::doEvalHook( $win, 'enable_attr_hook', $path,
                        "normal", $node );
                    return ( defined $enable_attr && $enable_attr eq 'stop' )
                        ? 0
                        : 1;
                },
                $win,
                $attr_path,
                $node
            ],
            choices_callback => [
                sub {
                    my ( $win, $base_path, $node, $path, $mtype, $editor )
                        = @_;
                    return main::doEvalHook( $win, 'attr_choices_hook', $path,
                        $node, $mtype, $editor );
                },
                $win,
                $attr_path,
                $node
            ],
            validate_callback => [
                sub {
                    my ( $win, $base_path, $node, $txt, $path, $mtype,
                        $editor )
                        = @_;
                    my $res
                        = main::doEvalHook( $win, 'attr_validate_hook', $txt,
                        $path, $node, $mtype, $editor );
                    defined $res ? $res : 1;
                },
                $win,
                $attr_path,
                $node
            ],
            attribute_sort_callback => [
                sub {
                    my ( $win, $node, $array, $path ) = @_;
                    return main::doEvalHook( $win, 'sort_attrs_hook', $array,
                        $path, $node );
                },
                $win,
                $node
            ],
            value_sort_callback => [
                sub {
                    my ( $win, $node, $array, $path ) = @_;
                    return main::doEvalHook( $win, 'sort_attr_values_hook',
                        $array, $path, $node );
                },
                $win,
                $node
            ],
            search_field => length $attr_path ? 0 : 1,
            knit_support => 1,
            validate_flags => PML_VALIDATE_NO_CHILDNODES,
            set_command    => sub {
                my ($callback) = @_;
                $win->{FSFile}->notSaved(1) if $win->{FSFile};
                TrEd::Undo::save_undo(
                    $win,
                    TrEd::Undo::prepare_undo(
                        $win,                                  $dlg_title,
                        TrEd::Undo::undo_type_id('UNDO_DATA'), $node
                    )
                );
                TrEd::Bookmarks::last_action_bookmark( $win->{framegroup} );
                &$callback();
                if ( length $attr_path ) {
                    main::doEvalHook( $win, "after_edit_attr_hook", $node,
                        $attr_path, 1 );
                }
                else {
                    main::doEvalHook( $win, "after_edit_node_hook", $node,
                        1 );
                }
                }
        }
    );
    if ($result) {
        main::get_nodes_fsfile_tree( $win->{framegroup}, $win->{FSFile},
            $win->{treeNo} );
        main::redraw_fsfile_tree( $win->{framegroup}, $win->{FSFile},
            $win->{treeNo} );
    }
    else {
        if ( $attr_path eq $EMPTY_STR ) {
            main::doEvalHook( $win, "after_edit_node_hook", $node, 0 );
        }
        else {
            main::doEvalHook( $win, "after_edit_attr_hook", $node, $attr_path,
                0 );
        }
    }
    return $result;
}

# was main::editAttrsDialog
sub show_dialog {
    my ( $win, $node ) = @_;
    my $edit_node_hook_res
        = main::doEvalHook( $win, "do_edit_node_hook", $node );
    return
        if ( defined $edit_node_hook_res && $edit_node_hook_res eq 'stop' );
    return unless $win->{FSFile};
    return dialog_schema( $win, $node )
        if ( ref( $node->type )
        || ref( $win->{FSFile}->schema() ) );
    my @vals;
    my %e     = ();
    my @atord = $win->{FSFile}->FS->attributes;

    if ($sortAttrs) {
        @atord = sort { uc($a) cmp uc($b) } $win->{FSFile}->FS->attributes
            unless (
            main::doEvalHook( $win, "sort_attrs_hook", \@atord, '', $node ) );
    }
    my $rows = min( $maxDisplayedAttributes, $#atord + 1 );
    my ( $a, $b, $r );

    my $enabled
        = (
        main::doEvalHook( $win, 'enable_edit_node_hook', $node ) eq 'stop' )
        ? 0
        : 1;
    my @buttons = $enabled ? qw(OK Help Cancel) : ('Cancel');
    $win->toplevel->Busy( -recurse => 1 );
    my $d = $win->toplevel->DialogBox(
        -title   => "Edit Node",
        -width   => '10c',
        -buttons => \@buttons
    );
    $d->Subwidget('B_Help')->configure(
        -command => [
            sub {
                main::help_topic( shift, 'old_editnode_interface' );
                Tk->break;
            },
            $d
        ]
    ) if $enabled;
    $d->BindButtons;
    $d->BindReturn( $d, 1 );
    $d->BindEscape();
    my $ff = $d->Frame(
        -relief => 'groove',
        -bd     => 1
    );
    my $f = $ff->Scrolled(
        'Pane',
        -sticky     => 'we',
        -scrollbars => 'oe'
    );
    main::disable_scrollbar_focus($f);
    $f->BindMouseWheelVert( $EMPTY_STR, "EditEntry" );

    my $lwidth;
    foreach (@atord) {
        $lwidth = TrEd::MinMax::max2( $lwidth, length($_) );
    }
    my $height = 0;

    for ( my $i = 0; $i <= $#atord; $i++ ) {
        $_ = $atord[$i];

        # Reliefs: raised, sunken, flat, ridge, and groove.
        my $eef = $f->Frame()->pack(qw/-side top -expand yes -fill x/);
        $eef->Label(
            -text      => $_,
            -underline => 0,
            -justify   => 'left',
            -width     => $lwidth,
            -anchor    => 'nw'
        )->pack(qw/-side left/);

        if (   $win->{FSFile}->FS->isList($_)
            or $node->get_member($_) =~ /^(?:[^\|\\]|\\.)*\|/ )
        {    # readonly entry and buttons for list
            $r = $eef->Frame();
            $e{$_} = $r->Entry(
                -relief    => 'sunken',
                -takefocus => 1,
                -font      => $font
            )->pack(qw/-expand yes -fill both -side left/);
            main::addBindTags( $e{$_}, "EditEntry" );
            $b = $r->Button(
                -text      => "...",
                -takefocus => 0,
                -command   => [
                    sub {
                        my ( $e, $win, $node, $attr, $d ) = @_;
                        my $result = (
                            $win->{FSFile}->FS->isList($attr)
                            ? main::editListAttr( $win, $e->get, $attr, $d,
                                $node )
                            : main::editAmbiguousAttr(
                                $win, $e->get, $attr, $d
                            )
                        );
                        if ( defined $result ) {
                            $e->configure( -state => 'normal' );
                            $e->delete( 0, length( $e->get ) );
                            $e->insert( 0, $result );
                            $e->configure( -state => 'disabled' );
                        }
                    },
                    $e{$_},
                    $win,
                    $node,
                    $_,
                    $d
                ]
            )->pack(qw/-side right/);
            $e{$_}->bind( $e{$_}, '<space>',
                [ sub { shift; shift->invoke; Tk->break; }, $b ] );
            $e{$_}->bind( $e{$_}, '<Return>',
                [ sub { shift; shift->invoke; Tk->break; }, $b ] );
            $d->BindReturn( $e{$_} );
            $e{$_}->bind( $e{$_}, '<Double-ButtonPress-1>',
                [ sub { shift; shift->invoke; Tk->break; }, $b ] );
            $e{$_}->insert( 0, encode( $node->get_member($_) ) );
            $e{$_}->configure( -state => 'disabled' );
            $r->pack(qw/-side right -expand yes -fill both/);
            $height += max2( $b->reqheight, $e{$_}->reqheight() )
                if ( $i < $rows );
        }
        else {
            $e{$_} = $eef->Entry(
                -relief    => 'sunken',
                -takefocus => 1,
                -font      => $font
            )->pack(qw/-side right -expand yes -fill both/);
            main::addBindTags( $e{$_}, "EditEntry" );
            $e{$_}->insert( 0, encode( $node->get_member($_) ) );
            if ( main::doEvalHook( $win, 'enable_attr_hook', $_, "normal" ) eq
                'stop' )
            {
                $e{$_}->configure( -state => 'disabled' );
            }
            $height += $e{$_}->reqheight() if ( $i < $rows );
        }
        $f->bind( $e{$_}, '<Tab>',
            [ \&main::focusxEditDn, $i, \%e, $f, \@atord ] );
        $f->bind( $e{$_}, '<Down>',
            [ \&main::focusxEditDn, $i, \%e, $f, \@atord ] );
        $f->bind( $e{$_}, '<Shift-Tab>',
            [ \&main::focusxEditUp, $i, \%e, $f, \@atord ] );
        $f->bind( $e{$_}, '<Shift-ISO_Left_Tab>',
            [ \&main::focusxEditUp, $i, \%e, $f, \@atord ] );
        $f->bind( $e{$_}, '<Up>',
            [ \&main::focusxEditUp, $i, \%e, $f, \@atord ] );
        $f->bind( $e{$_}, '<Alt-KeyPress>',
            [ \&main::focusxFind, $i, \%e, $f, \@atord ] );
    }

    $f->configure( -height => $height );
    $f->pack(qw/-expand yes -fill both/);
    $ff->pack(qw/-expand yes -fill both/);
    $win->toplevel->Unbusy();

    my $result
        = TrEd::Dialog::FocusFix::show_dialog( $d,
        ( $atord[0] ? $e{ $atord[0] }->focus : undef ),
        $win->toplevel );

    if ( $result =~ /OK/ ) {
        $win->{FSFile}->notSaved(1);
        TrEd::Undo::save_undo(
            $win,
            TrEd::Undo::prepare_undo(
                $win,                                  'Edit Node',
                TrEd::Undo::undo_type_id('UNDO_DATA'), $node
            )
        );
        TrEd::Bookmarks::last_action_bookmark( $win->{framegroup} );
        foreach $a (@atord) {
            $node->set_member( $a, decode( $e{$a}->get ) );
        }
        main::doEvalHook( $win, "after_edit_node_hook", $node, 1 );
        main::get_nodes_fsfile_tree( $win->{framegroup}, $win->{FSFile},
            $win->{treeNo} );
        main::redraw_fsfile_tree( $win->{framegroup}, $win->{FSFile},
            $win->{treeNo} );
    }
    else {
        main::doEvalHook( $win, "after_edit_node_hook", $node, 0 );
    }

    undef %e;
    $d->destroy;
    return ( $result =~ /OK/ ) ? 1 : 0;
}

1;
