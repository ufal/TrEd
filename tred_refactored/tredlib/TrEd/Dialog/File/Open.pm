package TrEd::Dialog::File::Open;

use strict;
use warnings;

use TrEd::Config;
use TrEd::Utils qw{$EMPTY_STR};
use TrEd::File;

use Carp;

#######################################################################################
# Usage         : _extensions_from_filetypes($open_types)
# Purpose       : Create a list of extensions of supported $open_types
# Returns       : Space delimited string of accepted file extensions' types
# Parameters    : array_ref $open_types   -- reference to array of supported file extensions
# Throws        : no exception
# Comments      : For a detailed information on how $open_types should look like, see
#                 TrEd::Config::open_types array. Basically it is an array of array references.
#                 Each array reference contains a description of the file type and a reference
#                 to an array of possible file extension for this file type, e.g.
#                 ["Text file", [qw{.txt .log .rtf .me}]]
sub _extensions_from_filetypes {
    my ($filetypes_ref) = @_;
    return ref( $filetypes_ref ) ? join " ", map { "*" . $_ }
                                             map { @{ $_->[1] } }
                                             @{ $filetypes_ref }
                                 : "*";
}

#######################################################################################
# Usage         : get_open_filename($widget, -option => value, -option2 => value)
# Purpose       : Obtain the file name of file which will be opened
# Returns       : String -- the name of the file that the user had chosen to be opened
# Parameters    : Tk::Widget $widget -- reference to top widget
#                 array @options     -- -option => value pairs
# Throws        : Carp if Tk dialog returns string in UTF-8 encoding
# Comments      : Options recognized as second argument are:
#                 -filetypes  => $array_ref -- possible file types
#                 -title      => $string    -- title of the dialog
#                 -initialdir => $string    -- which directory to load initially in the dialog
# See Also      : _extensions_from_filetypes(), Tk::Widget::getOpenFile(), Encode::encode
sub get_open_filename {
    my $widget = shift;
    my %opts = @_;
    my $open_filename;
    if ($TrEd::Config::openFilenameCommand) {
        my $open_command = $TrEd::Config::openFilenameCommand;
        my $types = _extensions_from_filetypes($opts{-filetypes});
        my $title      = $opts{-title}      || 'Open';
        my $initialdir = $opts{-initialdir} || q{.};
        $open_command =~ s/\%t/"$title"/gmxs;
        $open_command =~ s/\%m/"$types"/gmxs;
        $open_command =~ s/\%d/"$initialdir"/gmxs;
        $open_filename = `$open_command`;
        foreach my $filename ($open_filename) {
            $filename =~ s/\s+$//sx;
        }
    }
    else {
        require Encode;
        $open_filename = $widget->getOpenFile(%opts);
        if ( Encode::is_utf8($open_filename) ) {
            carp("Tk dialog returned a UTF-8 string as a filename, "
                ." forcing bytes using iso-8859-1!\n");
            $open_filename = Encode::encode('iso-8859-1', $open_filename);
        }
    }
    return $open_filename;
}

#######################################################################################
# Usage         : show_dialog($grp, $header_only)
# Purpose       : Create open file dialog
# Returns       : If file name is empty or not specified by get_open_filename function,
#                 returns 0.
#TODO: doplnit podla toho, co vracia open_standalone_file
# Parameters    : hash_ref $grp  -- reference to TrEd's hash of options and variables
#                 ? $header_only -- variable passed to open_standalone_file function
# Throws        : no exception
# Comments      :
# See Also      : TrEd::File::open_standalone_file(), get_open_filename()
sub show_dialog {
    my ($grp, $header_only) = @_;
    my $file;
    my $win = $grp->{focusedWindow};
    my $dir;
    if ($win->{FSFile}) {
        $dir = TrEd::File::dirname( $win->{FSFile}->filename );
    }
    $file = get_open_filename(
        $grp->{top},
        -filetypes => \@TrEd::Config::open_types,
        ( (defined $dir && -d $dir) ? ( -initialdir => $dir ) : () )
    );
    if ( defined $file && $file ne $EMPTY_STR ) {
        return TrEd::File::open_standalone_file( $grp, $file,
            -justheader => $header_only );
    }
    return 0;
}

1;

__END__


=head1 NAME


TrEd::Dialog::File::Open -- simple open file dialog


=head1 VERSION

This documentation refers to
TrEd::Dialog::File::Open version 0.1.


=head1 SYNOPSIS

  use TrEd::Dialog::File::Open;


=head1 DESCRIPTION

This package provides basic open file dialog for TrEd.

=head1 SUBROUTINES/METHODS

=over 4




=back


=head1 DIAGNOSTICS

Carps if the Tk's open file dialog returns file name in UTF-8

=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES



=head1 INCOMPATIBILITIES


=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to
Zdenek Zabokrtsky <zabokrtsky@ufal.ms.mff.cuni.cz>

Patches are welcome.


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

Copyright (c)
2010 Petr Pajas <pajas@matfyz.cz>
2011 Peter Fabian (documentation & tests).
All rights reserved.


This software is distributed under GPL - The General Public Licence.
Full text of the GPL can be found in the LICENSE file distributed with
this program and also on-line at http://www.gnu.org/copyleft/gpl.html .

=cut

