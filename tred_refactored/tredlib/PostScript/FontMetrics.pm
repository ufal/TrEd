# RCS Status      : $Id: FontMetrics.pm 286 2001-08-06 09:09:06Z pajas $
# Author          : Johan Vromans
# Created On      : December 1998
# Last Modified By: Johan Vromans
# Last Modified On: Wed Nov 15 14:47:38 2000
# Update Count    : 431
# Status          : Released

################ Module Preamble ################

package PostScript::FontMetrics;

use strict;
use Carp;

BEGIN { require 5.005; }

use IO::File;
use File::Spec;

use vars qw($VERSION);
$VERSION = "1.03";

# The ttftot42 program is used to extract metrics from True Type fonts.
use vars qw($ttftot42);

use constant FONTSCALE => 1000;		# normal value for font design

my $trace;
my $verbose;
my $debug;
my $error;

sub new {
    my $class = shift;
    my $font = shift;
    my (%atts) = (error => 'die',
		  verbose => 0, trace => 0,
		  @_);
    my $self = { file => $font };
    bless $self, $class;

    $debug = lc($atts{debug});
    $trace = $debug || lc($atts{trace});
    $verbose = $trace || lc($atts{verbose});
    $error = lc($atts{error});

    $ttftot42 = _getexec ("ttftot42")
      unless defined $ttftot42;

    eval { $self->_loadafm };
    if ( $@ ) {
	die ($@)  unless $error eq "warn";
	warn ($@) unless $error eq "ignore";
	return;
    }

    $self;
}

sub FileName	{ my $self = shift; $self->{file};    }

sub MetricsData { my $self = shift; $self->{data};    }

sub CharWidthData {
    my $self = shift;
    $self->_getwidthdata() unless defined $self->{Wx};
    $self->{Wx};
}

sub EncodingVector {
    my $self = shift;
    $self->_getwidthdata() unless defined $self->{encodingvector};
    $self->{encodingvector};
}

sub CharBBoxData {
    my $self = shift;
    $self->_getbboxdata() unless defined $self->{BBox};
    $self->{BBox};
}

sub KernData {
    my $self = shift;
    $self->_getkerndata() unless defined $self->{Kern};
    $self->{Kern};
}

sub _loadafm ($) {

    my ($self) = shift;

    my $data;			# afm data

    my $fn = $self->{file};
    my $fh = new IO::File;	# font file
    my $sz = -s $fn;	# file size

    $fh->open ($fn) || die ("$fn: $!\n");
    print STDERR ("$fn: Loading AFM file\n") if $verbose;

    # Read in the afm data.
    my $len = 0;
    unless ( ($len = $fh->sysread ($data, 4, 0)) == 4 ) {
      die ("$fn: Expecting $sz bytes, got $len bytes\n") unless ($^O eq 'MSWin32');
    }

    $self->{origdataformat} = 'afm';
    if ( $data eq "\0\1\0\0" ) {
	#### WARNING: This is Unix specific! ####
	my $cmd = $ttftot42 || $PostScript::Font::ttftot42;
	my $f = _qtfn($fn);
	if ( $cmd ) {
	    $cmd .= " -ac $f 2>>/dev/null |";
	    print STDERR ("$fn: Extracting metrics from True Type font\n")
	      if $verbose;
	}
	else {
	    die ("$fn: Cannot extract metrics from True Type font\n");
	}

	$fh->close;
	print STDERR ("+ $cmd\n") if $trace;
	$fh->open ($cmd) || die ("$cmd: $!\n");;
	$sz = -1;
	$len = 0;
	$self->{origdataformat} = 'ttf';
    }

    while ( $fh->sysread ($data, 32768, $len) > 0 ) {
	$len = length ($data);
    }
    $fh->close;
    print STDERR ("Read $len bytes from $fn\n") if $trace;

    die ("$fn: Expecting $sz bytes, got $len bytes\n")
	unless $^O eq 'MSWin32' || $sz == -1 || $sz == $len;

    # Normalise line endings. Get rid of trailing space as well.
    $data =~ s/\s*\015\012?/\n/g;

    if ( $data !~ /StartFontMetrics/ || $data !~ /EndFontMetrics/ ) {
	die ("$fn: Not a recognizable AFM file\n");
    }
    $self->{data} = $data;

    # Initially, we only load the "global" info from the AFM data.
    # Other parts are parsed when required.
    local ($_);
    foreach ( split (/\n/, $self->{data}) ) {
	next if /^StartKernData/ .. /^EndKernData/;
	next if /^StartComposites/ .. /^EndComposites/;
	next if /^StartCharMetrics/ .. /^EndCharMetrics/;
	last if /^EndFontMetrics/;
	if ( /^FontBBox\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s*$/ ) {
	    $self->{fontbbox} = [$1,$2,$3,$4];
	}
	elsif ( /(^\w+)\s+(.*)/ ) {
	    my ($key, $val) = ($1, $2);
	    $key = lc ($key);
	    if ( defined $self->{$key}) {
		$self->{$key} = [ $self->{$key} ] unless ref $self->{$key};
		push (@{$self->{$key}}, $val);
	    }
	    else {
		$self->{$key} = $val;
	    }
	}
    }

    $self;
}

sub _getwidthdata {
    # This is adapted from Gisle Aas' Font-AFM 1.17
    my $self = shift;
    local ($_);
    my %wx;
    unless ( defined $self->{encodingvector} ) {
	if ( defined $self->{encodingscheme} ) {
	    if ( $self->{encodingscheme} eq "AdobeStandardEncoding" ) {
		require PostScript::StandardEncoding;
		$self->{encodingvector} =
		  [ @{PostScript::StandardEncoding->array} ];
	    }
	    else {
		$self->{encodingvector} = [];
	    }
	}
    }
    my $enc = $self->{encodingvector};
    my $nglyphs = 0;
    my $nenc = 0;
    foreach ( split (/\n/, $self->{data}) ) {
	if ( /^StartCharMetrics/ .. /^EndCharMetrics/ ) {
	    # Only lines that start with "C" or "CH" are parsed.
	    next unless /^CH?\s+(-?\d+)\s*;/;
	    my $ix = $1;
	    my ($name) = /\bN\s+(\.?\w+)\s*;/;
	    my ($wx)   = /\bWX\s+(\d+)\s*;/;
	    $wx{$name} = $wx;
	    $nglyphs++;
	    $enc->[$ix] = $name, $nenc++ unless $ix < 0;
	    next;
	}
	last if /^EndFontMetrics/;
    }
    unless ( exists $wx{'.notdef'} ) {
	$wx{'.notdef'} = 0;
    }
    print STDERR ($self->FileName, ": Number of glyphs = $nglyphs, ",
		  "encoded = $nenc\n") if $verbose;
    $self->{Wx} = \%wx;
    $self;
}

sub _getbboxdata {
    # This is adapted from Gisle Aas' Font-AFM 1.17
    my $self = shift;
    local ($_);
    my %bbox;
    foreach ( split (/\n/, $self->{data}) ) {
	if ( /^StartCharMetrics/ .. /^EndCharMetrics/ ) {
	    # Only lines that start with "C" or "CH" are parsed.
	    next unless /^CH?\s/;
	    my ($name) = /\bN\s+(\.?\w+)\s*;/;
	    my (@bbox) = /\bB\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s+(-?\d+)\s*;/;
	    $bbox{$name} = \@bbox;
	    next;
	}
	last if /^EndFontMetrics/;
    }
    unless ( exists $bbox{'.notdef'} ) {
	$bbox{'.notdef'} = [0, 0, 0, 0];
    }
    $self->{BBox} = \%bbox;
    $self;
}

sub _getkerndata {
    my $self = shift;
    local ($_);
    my %kern;
    foreach ( split (/\n/, $self->{data}) ) {
	if ( /^StartKernData/ .. /^EndKernData/ ) {
	    next unless /^KPX\s+(\S+)\s+(\S+)\s+(-?\d+)/;
	    $kern{$1,$2} = $3;
	}
	last if /^EndFontMetrics/;
    }
    ${kern}{'.notdef','.notdef'} = 0 unless %kern;
    $self->{Kern} = \%kern;
    $self;
}

sub setEncoding {
    my ($self, $enc) = @_;
    if ( ref($enc) && UNIVERSAL::isa($enc,'ARRAY') && scalar(@$enc) == 256 ) {
	# Array ref is okay.
    }
    elsif ( $enc eq "StandardEncoding" ) {
	require PostScript::StandardEncoding;
	$enc = [ @{PostScript::StandardEncoding->array} ];
    }
    elsif ( $enc eq "ISOLatin1Encoding" ) {
	require PostScript::ISOLatin1Encoding;
	$enc = [ @{PostScript::ISOLatin1Encoding->array} ];
    }
    else {
	croak ("Invalid encoding vector");
    }
    $self->{encodingvector} = $enc;
    delete $self->{_charcache};
    $self;
}

sub stringwidth {
    my ($self, $string, $pt) = @_;

    my $wx = $self->CharWidthData;
    my $ev = $self->EncodingVector;
    if ( scalar(@{$self->{encodingvector}}) <= 0 ) {
	die ($self->FileName . ": Missing Encoding\n");
    }
    my $wd = 0;
    foreach ( unpack ("C*", $string) ) {
	$wd += $wx->{$ev->[$_]||'.undef'};
    }

    if ( defined $pt ) {
	carp ("Using a PointSize argument to stringwidth is deprecated")
	  if $^W;
	$wd *= $pt / FONTSCALE;
    }
    $wd;
}

sub kstringwidth {
    my ($self, $string, $pt) = @_;

    my $wx = $self->CharWidthData;
    my $ev = $self->EncodingVector;
    if ( scalar(@{$self->{encodingvector}}) <= 0 ) {
	croak ($self->FileName . ": Missing Encoding\n");
    }
    my $kr = $self->KernData;
    my $wd = 0;
    my $prev;
    foreach ( unpack ("C*", $string) ) {
	my $this = $ev->[$_] || '.undef';
	$wd += $wx->{$this};
	if ( defined $prev ) {
	    my $kw = $kr->{$prev,$this};
	    $wd += $kw if defined $kw;
	}
	$prev = $this;
    }
    if ( defined $pt ) {
	carp ("Using a PointSize argument to kstringwidth is deprecated")
	  if $^W;
	$wd *= $pt / FONTSCALE;
    }
    $wd;
}

sub kstring {
    my ($self, $string, $ext) = @_;
    return (wantarray ? () : []) unless length ($string);

    my $wx = $self->CharWidthData;
    my $ev = $self->EncodingVector;
    if ( scalar(@{$self->{encodingvector}}) <= 0 ) {
	croak ($self->FileName . ": Missing Encoding\n");
    }
    my $kr = $self->KernData;
    my $wd = (defined $ext ? $wx->{'space'}+$ext : 0);
    my @res = ();
    my $prev = '.undef';

    foreach ( split ('', $string) ) {

	# Check for flex space.
	if ( defined $ext && $_ eq " " ) {
	    # If we have something, accumulate.
	    if ( @res ) {
		# Add to displacement.
		if ( $prev eq 'space' ) {
		    $res[$#res] += $wd;
		}
		# Turn last item into string, and push the displacement.
		else {
		    $res[$#res] =~ s/([()\\]|[^\040-\176])/sprintf("\\%o",ord($1))/eg;
		    $res[$#res] = "(".$res[$#res].")";
		    push (@res, $wd);
		}
	    }
	    else {
		# First item, push.
		push (@res, $wd);
	    }
	    $prev = 'space';
	    next;
	}

	# Get the glyph name and kern value.
	my $this = $ev->[ord($_)] || '.undef';
	my $kw = $kr->{$prev,$this} || 0;
	{ local ($^W) = 0;
	  print STDERR ("$prev $this $kw :$res[-3]:$res[-2]:$res[-1]:\n")
	    if $debug;
        }
	# Nothing to kern?
	if ( defined $ext && $prev eq 'space' ) {
	    # Accumulate displacement.
	    $res[$#res] += $kw;
	    push (@res, $_);
	}
	elsif ( $kw == 0 ) {
	    if ( $prev eq '.undef' ) {
		# New item.
		push (@res, $_);
	    }
	    else {
		# Accumulate text.
		$res[$#res] .= $_;
	    }
	}
	else {
	    # Turn previous into string.
	    $res[$#res] =~ s/([()\\]|[^\040-\176])/sprintf("\\%o",ord($1))/eg;
	    $res[$#res] = "(".$res[$#res].")";
	    # Add kerning value and the new item.
	    push (@res, $kw, $_);
	}
	$prev = $this;
    }

    # Turn the last item into string, if needed.
    if ( !(defined $ext && $prev eq 'space') ) {
	$res[$#res] =~ s/([()\\]|[^\040-\176])/sprintf("\\%o",ord($1))/eg;
	$res[$#res] = "(".$res[$#res].")";
    }

    # Return.
    wantarray ? @res : \@res;
}

sub char {
    my ($self, $glyph) = @_;

    # Return from cache if possible.
    my $char = $self->{_charcache}->{$glyph};
    return $char if defined $char;

    # Look it up.
    $char = -1;
    foreach ( @{$self->EncodingVector} ) {
	$char++;
	next unless $_ eq $glyph;
	return $self->{_charcache}->{$glyph} = pack("C",$char);
    }
    undef;
}

sub _qtfn ($) {
    my $f = shift;
    $f =~ s/([\\'])/'\\$1'/g;
    "'".$f."'";
}

sub _getexec ($) {
    my ($exec) = @_;
    foreach ( File::Spec->path ) {
	if ( -x "$_/$exec" ) {
	    print STDERR ("Using $_/$exec\n") if $verbose;
	    return "$_/$exec";
	}
	elsif ( -x "$_/$exec.exe" ) {
	    print STDERR ("Using $_/$exec.exe\n") if $verbose;
	    return "$_/$exec.exe";
	}
    }
    '';
}

sub AUTOLOAD {
    # This is adapted from Gisle Aas' Font-AFM 1.17
    no strict 'vars';

    if ( $AUTOLOAD =~ /::DESTROY$/ ) {
	# Prevent the eval from clobbering outer eval error status.
	local ($@);
	# Define a dummy destoyer, and jump tp it.
	eval "sub $AUTOLOAD {}";
	goto &$AUTOLOAD;
    }
    else {
	my $name = $AUTOLOAD;
	$name =~ s/^.*:://;
	return $_[0]->{lc $name};
    }
}

1;

__END__

################ Documentation ################

=head1 NAME

PostScript::FontMetrics - module to fetch data from Adobe Font Metrics file

=head1 SYNOPSIS

  my $info = new PostScript::FontMetrics (filename, options);
  print STDOUT ("Name = ", $info->FontName, "\n");
  print STDOUT ("Width of LAV = ", $info->kstringwidth("LAV", 10), "\n");

=head1 DESCRIPTION

This package allows Adobe standard font metric files, so called
C<.afm> files, to be read and (partly) parsed.

True Type fonts are understood as well, their metrics are extracted.
Currently this requires an external program, I<ttftot42>. This program
will be used automatically if it can be located in the execution
C<PATH>. Alternatively, you can set the variable
C<$PostScript::FontMetrics::ttftot42> (or
C<$PostScript::Font::ttftot42>) to the name of the actual program. See
also L<EXTERNAL PROGRAMS>.

=head1 CONSTRUCTOR

=over 4

=item new ( FILENAME [ , OPTIONS ])

The constructor will read the file and parse its contents.

=back

=head1 OPTIONS

=over 4

=item error => [ 'die' | 'warn' | 'ignore' ]

How errors must be handled. Default is to call die().
In any case, new() returns a undefined result.

=item verbose => I<value>

Prints verbose info if I<value> is true.

=item trace => I<value>

Prints tracing info if I<value> is true.

=item debug => I<value>

Prints debugging info if I<value> is true.
Implies 'trace' and 'verbose'.

=back

=head1 INSTANCE METHODS

B<Note:> Most of the info from the AFM file can be obtained by calling a method of the same name, e.g. C<FontName> and C<IsFixedPitch>.

Each of these methods can return C<undef> if the corresponding
information could not be found in the file.

=over 4

=item FileName

The name of the file, e.g. 'tir_____.afm'.
This is not derived from the metrics data, but the name of the file as
passed to the C<new> method.

=item MetricsData

The complete contents of the file, normalised to Unix-style line endings.

=item CharWidthData

Returns a reference to a hash with the character widths for each glyph.

=item EncodingVector

Returns a reference to an array with the glyph names for each encoded
character.

=item CharBBoxData

Returns a reference to a hash with the bounding boxes (a 4-element
array) for each glyph.

=item KernData

Returns a reference to a hash with the kerning data for glyph pairs.
It is indexed by two glyph names (two strings separated by a comma,
e.g. $kd->{"A","B"}).

=item setEncoding ( vector )

Sets the current encoding vector. The argument must be a reference to
an array of exactly 256 elements, or the name of a pre-defined
encoding (C<"StandardEncoding"> or C<"ISOLatin1Encoding">).

=item stringwidth ( string [ , pointsize ] )

Returns the width of the string, in character space units.

Deprecated: When a pointsize argument is supplied, the resultant width
is scaled to user space units. This assumes that the font maps 1000
character space units to one user space unit (which is generally the
case).

=item kstringwidth ( string [ , pointsize ] )

Returns the width of the string in character space units, taking kerning
information into account.

Deprecated: When a pointsize argument is supplied, the resultant width
is scaled to user space units. This assumes that the font maps 1000
character space units to one user space unit (which is generally the
case).

=item kstring ( string [ , extent ] )

Returns an array reference (in scalar context) or an array (in array
context) with substrings of the given string, interspersed with
kerning info. The kerning info is the amount of movement needed for
the correct kerning, in character space (which is usually 1000 times a
PostScript point). The substrings are ready for printing: non-ASCII
characters have been encoded and parentheses are put around them.

If the extend argument is supplied, this amount of displacement is
added to each space in the string.

For example, for a given font, the following call:

    $typesetinfo = $metrics->kstring ("ILVATAB");

could return in $typesetinfo:

    [ "(IL)", -97, "(V)", -121, "(A)", -92, "(T)", -80, "(AB)" ]

There are several straightforward ways to process this.

By translating to a series of 'show' and 'rmoveto' operations:

    foreach ( @$typesetinfo ) {
	if ( /^\(/ ) {
	    print STDOUT ($_, " show\n");
	}
	else {
	    printf STDOUT ("%.3f 0 rmoveto\n", ($_*$fontsize)/$fontscale);
	}
    }

Or, assuming the following definition in the PostScript preamble (48
is the font size):

    /Fpt 48 1000 div def
    /TJ {{ dup type /stringtype eq
      { show }
      { Fpt mul 0 rmoveto }
      ifelse } forall } bind def

the following Perl code would suffice:

    print PS ("[ @$typesetinfo ] TJ\n");

=item char

Returns a one-character string that will render as the named glyph in
the current encoding, or C<undef> if this glyph is currently not
encoded.

=back

=head1 EXTERNAL PROGRAMS

I<ttftot42> is required when True Type fonts must be handled. It is
called as follows:

    ttftot42 -ac filename

This invocation will write the metrics for the True Type font to
standard output.

I<ttftot42> can be found on http://ftp.giga.or.at/pub/nih/ttftot42

=head1 SEE ALSO

=over 4

=item http://partners.adobe.com/asn/developer/PDFS/TN/5004.AFM_Spec.pdf

The specification of the Adobe font metrics file format.

=back

=head1 AUTHOR

Johan Vromans, Squirrel Consultancy <jvromans@squirrel.nl>

=head1 COPYRIGHT and DISCLAIMER

This program is Copyright 2000,1998 by Squirrel Consultancy. All
rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of either: a) the GNU General Public License as
published by the Free Software Foundation; either version 1, or (at
your option) any later version, or b) the "Artistic License" which
comes with Perl.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See either the
GNU General Public License or the Artistic License for more details.

=cut
