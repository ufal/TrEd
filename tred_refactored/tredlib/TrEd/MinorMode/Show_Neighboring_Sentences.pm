# -*- cperl -*-
package TrEd::MinorMode::Show_Neighboring_Sentences;

use strict;
use warnings;

require TrEd::ExtensionsAPI;
TredMacro->import();

require TrEd::Macros;
require Treex::PML;
require TrEd::MinMax;

require TrEd::MinorModes;

my $cfg = QuickPML(
    cfg => [
        'structure',
        context_before => 'nonNegativeInteger',
        context_after  => 'nonNegativeInteger',
    ],
    Treex::PML::Factory->createStructure(
        {   context_before => 5,
            context_after  => 5,
        }
    )
);

sub edit_configuration {
    ToplevelFrame()->TrEdNodeEditDlg(
        {   title        => 'Edit Parameters',
            type         => $cfg->schema->get_root_type,
            object       => get_config(),
            search_field => 0,
            focus        => 'context_before',
            no_sort      => 1,
        }
    );
    ChangingFile(0);
}

sub configure {
    my ( $before, $after ) = @_;
    for my $c ( get_config() ) {
        $c->{context_before} = int($before);
        $c->{context_after}  = int($after);
    }
}

sub get_config {
    return $cfg->get_root;
}

sub _get_value_line_hook {
    my ( $fsfile, $no, $type ) = @_;
    print ".........................value line hook in show neighb sent\n";
    return if ($type ne 'value_line');
    # it is really a grp_ref, probably, so it can be changed...
    my $grp = TrEd::Macros::get_macro_variable('grp');
    if ( !defined $_[-1] ) {

        # value line not supplied by hook, we provide the standard one
        $_[-1] = $grp->treeView->value_line( $fsfile, $no, 1, 1, $grp );
    }
    elsif ( !ref $_[-1] ) {
        $_[-1] = [ [ $_[-1] ] ];
    }
    use Data::Dumper;
    $Data::Dumper::Maxdepth = 2;
    print Dumper(\@_);
    my $vl = $_[-1];
    # put '-->' at the beginning of the array @{$vl} and newline at the end
    unshift @{$vl}, [ '--> ', $fsfile->tree($no) ];
    push @{$vl}, ["\n"];
    my $sub = UNIVERSAL::can( TredMacro::CurrentContext(), 'get_value_line_hook' )
        || UNIVERSAL::can( 'TredMacro', 'get_value_line_hook' );
    my ( $before, $after )
        = map { $_->{context_before}, $_->{context_after} } get_config();
    my $first = TrEd::MinMax::max( $no - $before, 0 );
    my $last = TrEd::MinMax::min( $no + $after, $fsfile->lastTreeNo() );

    for my $i ( reverse( $first .. $no - 1 ), $no + 1 .. $last ) {
        my $res = $sub && $sub->( $fsfile, $i );
        $res = $grp->treeView->value_line( $fsfile, $i, 1, 1, $grp )
            unless defined $res;
        if ( $i > $no ) {
            push @{$vl},
                map { push @{$_}, '-foreground => #777'; $_ }
                ( ref $res ? @{$res} : [$res] ), ["\n"];
        }
        else {
            unshift @{$vl},
                map { push @{$_}, '-foreground => #777'; $_ }
                ( ref $res ? @{$res} : [$res] ), ["\n"];
        }
    }

    # return $vl;
}

sub _value_line_doubleclick_hook {
    use Data::Dumper;
    $Data::Dumper::Maxdepth = 2;
    print Dumper(\@_);

    my $res = $_[-1];
    if (defined $res && $res eq 'stop') {
        return;
    }
    my %tags;
    @tags{ @_[ 0 .. $#_ - 1 ] } = ();
    if ( !ref $res ) {
        my ( $before, $after )
            = map { $_->{context_before}, $_->{context_after} } get_config();
        my $fsfile = CurrentFile();
        print "fsfile 1: $fsfile\n";
        my $grp = TrEd::Macros::get_macro_variable('grp');
        print "grp/win = $grp\n";
        print "fsfile 2: " . $grp->{FSFile} . "\n";
        $fsfile = $grp->{FSFile};

        print "before: $before\n";
        print "after: $after\n";

        my $no     = CurrentTreeNumber();
        print "no: $no\n";
        my $first  = max( $no - $before, 0 );
        my $last   = min( $no + $after, $fsfile->lastTreeNo() );

        for my $i ( reverse( $first .. $no - 1 ), $no + 1 .. $last ) {
            my $tree = $fsfile->tree($i);
            while ($tree) {
                if ( exists $tags{"$tree"} ) {
                    GotoTree( $i + 1 );

                    #TODO: is this 'this' going to work..?
                    #$this=$tree;
                    TrEd::Macros::set_macro_variable( 'this', $tree );
                    Redraw();
                    $_[-1] = 'stop';
                }
                $tree = $tree->following();
            }
        }
    }
}

sub init_minor_mode {
    my ($grp) = @_;

    return if !TrEd::Macros::is_defined('TRED');

    TrEd::MinorModes::declare_minor_mode( $grp, 'Show_Neighboring_Sentences' => {
            abbrev     => 'neigh_sent',
            configure  => \&edit_configuration,
            post_hooks => {
                get_value_line_hook         => \&_get_value_line_hook,
                value_line_doubleclick_hook => \&_value_line_doubleclick_hook,
            },
        }
    );
}

1;
