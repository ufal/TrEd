# simple html
package TrEd::HTML::Simple;

use strict;
use warnings;

use TrEd::Utils qw{$EMPTY_STR set_fh_encoding};
use TrEd::File;
use TrEd::Error::Message;
use TrEd::Convert;

sub open {
    my ( $top, $file, $title, $initdir ) = @_;
    $file = main::get_save_filename(
        $top->toplevel,
        -filetypes => [
            [ "HTML", [ '.html', '.htm', '.HTM', '.HTML' ] ],
            [ "All files", "*" ]
        ],
        -title => $title,
        -d $initdir ? ( -initialdir => $initdir ) : (),
        $^O eq 'MSWin32'
        ? ()
        : ( -initialfile => TrEd::File::filename($file) )
    );

    # Add .html ending if it does not have one
    if ( $file !~ m/\.htm(:?l)?$/i ) {
        $file .= '.html';
    }
    if ( defined($file) and $file ne $EMPTY_STR ) {
        open my $html, ">$file"
            || TrEd::Error::Message::error_message(
            $top,
            "Cannot write to \"$file\"!" . "\n("
                . main::conv_from_locale($!)
                . "\nCheck file and directory permissions.\n"
                . "\nSentences could not be saved!",
            1
            );
        my $encoding = $TrEd::Convert::outputenc;
        if ($TrEd::Convert::support_unicode) {
            TrEd::Utils::set_fh_encoding( $html, $encoding, "html-out" );
        }
        else {
            TrEd::Utils::set_fh_encoding( $html, ':bytes', "html-out" );
        }
        print $html "<html>\n";
        print $html "<head>\n";
        print $html
            "  <meta http-equiv=\"Content-Type\" content=\"text/html;charset="
            . $encoding
            . "\" />\n";
        print $html "</head>\n";
        print $html "<body>\n";
        return wantarray ? ( $html, $file ) : $html;
    }
    else {
        return;
    }
}

# simple html
sub close {
    my ($html) = @_;
    print $html "\n</body>\n";
    print $html "\n</html>\n";
    close($html);
}

1;
