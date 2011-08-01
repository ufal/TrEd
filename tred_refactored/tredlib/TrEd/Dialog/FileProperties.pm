package TrEd::Dialog::FileProperties;

use strict;
use warnings;

use TrEd::Config qw{$sortAttrValues $sidePanelWrap};

# dialog
# was main::editFilePropertiesDialog
sub show_dialog {
    my ($grp_or_win) = @_;
    my ( $grp, $win ) = main::grp_win($grp_or_win);
    my $top    = $grp->{top};
    my $fsfile = $win->{FSFile};
    return unless $fsfile;
    my $trees_type = $fsfile->metaData('pml_trees_type');
    my $references = $fsfile->metaData('references');
    my $fsrequire  = $fsfile->metaData('fsrequire');
    my $refnames   = $fsfile->metaData('refnames');
    my %id2name    = $refnames ? ( reverse %$refnames ) : ();
    my $schema     = $fsfile->schema();
    my $text       = join(
        "\n",
        "File Information",
        "----------------",
        "URI:\t" . $fsfile->URL,
        "I/O Backend:\t" . $fsfile->backend,
        "Trees:\t" . ( $fsfile->lastTreeNo + 1 ),
        (   $schema
            ? ( "\n\nPML Schema Information",
                "----------------------",
                "Rrevision:\t" . $schema->get_revision(),
                "Root name:\t" . $schema->get_root_name(),
                "Description:\t" . $schema->get_description(),
                "URI:\t" . $schema->get_url(),
                "Tree list type:\t"
                    . ( ref($trees_type) ? $trees_type->get_decl_path : '-' ),
                (   map {
                        "\thas $_:\t"
                            . (
                            ref( $fsfile->metaData("pml_$_") )
                            ? "yes"
                            : "no" )
                        } qw(prolog epilog)
                ),
                )
            : ()
        ),
        (   ref($references)
            ? ( "\n\nPML References",
                "--------------",
                map {
                    my $name = $id2name{$_} || '';
                    $name = " [$name]" if $name;
                    "$_$name => $references->{$_}"
                    } keys %$references
                )
            : ()
        ),
        (   ref($fsrequire)
            ? ( "\n\nSecondary files",
                "---------------",
                ( map {"$_->[0] => $_->[1]"} @$fsrequire ),
                )
            : ()
        ),
    );
    my $ret = $top->ErrorReport(
        -title   => 'Properties',
        -msgtype => ('INFORMATION'),
        -message => ("Current File Properties"),
        -body    => $text,
        -buttons => [
            'Close',
            (   map {
                    $schema && ref( $fsfile->metaData("pml_$_") )
                        ? 'View ' . ucfirst($_) . ' Data'
                        : ()
                    } qw(root prolog epilog)
            )
        ]
    );
    my $what = $ret;
    if ( $what =~ s/ (.*) Data/$1/ ) {
        $what = 'pml_' . lc($1);
        my $type = $what eq 'pml_root' ? $schema->get_root_type : $trees_type;

        #    print STDERR "$what: ",$fsfile->metaData($what),"\t",$type,"\n";
        $top->TrEdNodeEditDlg(
            {   title => $ret,
                type  => $type
                ,    # fixme: what data type for pml_epliog and pml_prolog?
                object       => $fsfile->metaData($what),
                object_name  => $what,
                search_field => 1,
                allow_trees  => $what eq 'pml_root' ? 0 : 1,
                enable_callback => sub {0},
                no_sort         => 1,
                no_value_sort   => !$TrEd::Config::sortAttrValues,
                side_panel_wrap => $TrEd::Config::sidePanelWrap,
            }
        );
    }

    # $top->TrEdNodeEditDlg({
    #   title => 'Edit Properties',
    #   type => $cfg->schema->get_root_type,
    #   object => get_config(),
    #   search_field => 0,
    #   focus => 'context_before',
    #   no_sort=>1,
    # });

}

1;
