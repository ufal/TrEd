package TrEd::Dialog::URL;

use strict;
use warnings;

use TrEd::File;
use TrEd::Config qw{tilde_expand};
use URI::file;
use TrEd::Utils qw{$EMPTY_STR};
use Scalar::Util qw(blessed);
use List::Util qw{max};
require TrEd::Query::String;

# was main::urlDialog
sub create_dialog {
    my ( $grp, $header_only ) = @_;
    if ( not( defined $grp->{lastURL} )
        and defined( $grp->{focusedWindow}->{FSFile} ) )
    {
        $grp->{lastURL} = $grp->{focusedWindow}->{FSFile}->filename();
    }
    $grp->{lastURL} ||= 'file://';
    $grp->{urlHist} = [] unless ref( $grp->{urlHist} );
    my $opts = {};
    if ( eval { require Tk::MatchEntry; 1 } ) {
        $opts = {
            -entry => [
                'MatchEntry',
                -label      => undef,
                -choices    => [],
                -complete   => 1,
                -wraparound => 1,
                -autopopup  => 1,
                -fixedwidth => 0,
                -autoshrink => 1,
                -maxheight  => 10,
                -listcmd    => sub {
                    my ($w) = @_;
                    my $file = $w->Subwidget('entry')->get();
                    my @files;
                    if ( $file !~ m{^\s*([[:alnum:]][[:alnum:]]+):} ) {
                        @files
                            = glob( TrEd::Config::tilde_expand($file) . '*' );
                    }
                    elsif ( $file =~ m{^\s*file:} ) {
                        $file = URI->new(
                            $file eq 'file:' ? 'file:///' : $file );
                        if ( ( blessed($file) && $file->isa('URI::file') ) ) {
                            @files = map { URI::file->new($_)->as_string }
                                glob( $file->file . '*' );
                        }
                    }
                    $w->configure( -choices => \@files );
                    my $font = $w->cget('-font');
                    $w->configure( -listwidth => 10
                            + max( map $w->fontMeasure( $font, $_ ), @files )
                    );
                    $w->xview('end');
                    }
            ],
            -entry_config => sub {
                $_[0]->Subwidget('entry')->Subwidget('entry')->configure(
                    -background => 'white',
                    -foreground => 'black',
                );
                $_[0]->focus;
            },
        };
    }
    else {
        undef $@;
    }
    my $file = TrEd::Query::String::new_query( $grp, "Enter URL", "URL: ",
        $grp->{lastURL}, 1, $grp->{urlHist}, undef, $opts );
    if ( defined $file && $file ne $EMPTY_STR ) {
        $grp->{lastURL} = $file;
        return TrEd::File::open_standalone_file( $grp, $file,
            -justheader => $header_only );
    }
    return 0;
}

1;
