
=head1 NAME

TrEd::ValLex::Sort

=cut

package TrEd::ValLex::Sort;

no locale;
use utf8;
use integer;
use strict;
use Exporter;
use vars qw( @ISA @EXPORT $VERSION $DEBUG );
@ISA = qw( Exporter );

#
# We implicitly export czcmp, czsort, cscmp and cssort functions.
# Since these are the only ones that can be used by ordinary users,
# it should not cause big harm.
#

$VERSION = '0.68';
$DEBUG = 0;
sub DEBUG	{ $DEBUG; }

#
# The table with sorting definitions.
#
my @def_table = (
	'aA áÁ âÂ ăĂ äÄ ąĄ',
	'bB',
	'cC ćĆ çÇ',		'čČ',
	'dD ďĎ đĐ',
	'eE éÉ ěĚ ëË ęĘ',
	'fF',	
	'gG',
	'hH',
	'<ch><Ch><CH>',
	'iI íÍ îÎ',
	'jJ',
	'kK',
	'lL ĺĹ ľĽ łŁ',
	'mM',
	'nN ńŃ ňŇ',
	'oO óÓ ôÔ öÖ őŐ',
	'pP',
	'qQ',
	'rR ŕŔ',		'řŘ',
	'sS śŚ şŞ',		'šŠ',
	'ß',
	'tT ťŤ ţŢ',
	'uU úÚ ůŮ üÜ űŰ',
	'vV',
	'wW',
	'xX',
	'yY ýÝ',
	'zZ żŻ źŹ',		'žŽ',
	'0',		'1',		'2',		'3',
	'4',		'5',		'6',		'7',
	'8',	'9',
	' .,;?!:"`\'',
	' -­|/\\()[]<>{}',
	' @&§%$',
	' _^=+×*÷#˘~',
	' ˙ˇ°¨˝¸˛',
	' ¤',
	);

#
# Conversion table will hold four arrays, one for each pass. They will
# be created on the fly if they are needed. We also need to hold
# information (regexp) about groups of letters that need to be considered
# as one character (ch).
#
my @table = ( );
my @regexp = ( '.', '.', '.', '.' );
my @multiple = ( {}, {}, {}, {} );

#
# Make_table will build sorting table for given level.
#
sub make_table
	{
	my $level = shift;
	@{$table[$level]} = ( undef ) x 256;
	@{$table[$level]}[ord ' ', ord "\t"] = (0, 0);
	my $i = 1;
	my $irow = 0;
	while (defined $def_table[$irow])
		{
		my $def_row = $def_table[$irow];
		next if $level <= 2 and $def_row =~ /^ /;
		while ($def_row =~ /<([cC].*?)>|(.)/sg)
			{
			my $match = $+;
			if ($match eq ' ')
				{
				if ($level == 1)
					{ $i++; }
				}
			else
				{
				if (length $match == 1)
					{ $table[$level][ord $match] = $i; }
				else
					{
					$multiple[$level]{$match} = $i;
					$regexp[$level] = $match . "|" . $regexp[$level];
					}
				if ($level >= 2)
					{ $i++; }
				}
			}
		$i++ if $level < 2;
		}
	continue
		{ $irow++; }
	}

#
# Create the tables now.
#
for (0 .. 3)
	{ make_table($_); }

#
# Compare two scalar, according to the tables.
#
sub czcmp
	{
	my ($a, $b) = (shift, shift);
	print STDERR "czcmp: $a/$b\n" if DEBUG;
	my ($a1, $b1) = ($a, $b);
	my $level = 0;
	while (1)
		{
		my ($ac, $bc, $a_no, $b_no, $ax, $bx) = ('', '', 0, 0,
			undef, undef);
		if ($level == 0)
			{
			while (not defined $ax and not $a_no)
				{
				$a =~ /($regexp[$level])/sg or $a_no = 1;
				$ac = $1;
				$ax = ( length $ac == 1 ?
					$table[$level][ord $ac]
					: ${$multiple[$level]}{$ac} )
						if defined $ac;
				}
			while (not defined $bx and not $b_no)
				{
				$b =~ /($regexp[$level])/sg or $b_no = 1;
				$bc = $1;
				$bx = ( length $bc == 1 ?
					$table[$level][ord $bc]
					: ${$multiple[$level]}{$bc} )
						if defined $bc;
				}
			}
		else
			{
			while (not defined $ax and not $a_no)
				{
				$a1 =~ /($regexp[$level])/sg or $a_no = 1;
				$ac = $1;
				$ax = ( length $ac == 1 ?
					$table[$level][ord $ac]
					: ${$multiple[$level]}{$ac} )
						if defined $ac;
				}
			while (not defined $bx and not $b_no)
				{
				$b1 =~ /($regexp[$level])/sg or $b_no = 1;
				$bc = $1;
				$bx = ( length $bc == 1 ?
					$table[$level][ord $bc]
					: ${$multiple[$level]}{$bc} )
						if defined $bc;
				}
			}

		print STDERR "level $level: ac: $ac -> $ax; bc: $bc -> $bx ($a_no, $b_no)\n" if DEBUG;

		return -1 if $a_no and not $b_no;
		return 1 if not $a_no and $b_no;
		if ($a_no and $b_no)
			{
			if ($level == 0)
				{ $level = 1; next; }
			last;
			}

		return -1 if ($ax < $bx);
		return 1 if ($ax > $bx);

		if ($ax == 0 and $bx == 0)
			{
			if ($level == 0)
				{ $level = 1; next; }
			$level = 0; next;
			}
		}
	for $level (2 .. 3)
		{
		while (1)
			{
			my ($ac, $bc, $a_no, $b_no, $ax, $bx)
				= ('', '', 0, 0, undef, undef);
			while (not defined $ax and not $a_no)
				{
				$a =~ /($regexp[$level])/sg or $a_no = 1;
				$ac = $1;
				$ax = ( length $ac == 1 ?
					$table[$level][ord $ac]
					: ${$multiple[$level]}{$ac} )
						if defined $ac;
				}
			while (not defined $bx and not $b_no)
				{
				$b =~ /($regexp[$level])/sg or $b_no = 1;
				$bc = $1;
				$bx = ( length $bc == 1 ?
					$table[$level][ord $bc]
					: ${$multiple[$level]}{$bc} )
						if defined $bc;
				}
			print STDERR "level $level: ac: $ac -> $ax; bc: $bc -> $bx ($a_no, $b_no)\n" if DEBUG;
			return -1 if $a_no and not $b_no;
			return 1 if not $a_no and $b_no;
			if ($a_no and $b_no)
				{ last; }
			return -1 if ($ax < $bx);
			return 1 if ($ax > $bx);
			}
		}
	return 0;
	}

1;

#
# Cssort does the real thing.
#
sub czsort
	{ sort { czcmp($a, $b) } @_; }

*cscmp = *czcmp;
*cssort = *czsort;

1;

__END__

=head1 DESCRIPTION

Implements czech sorting conventions. Based on Cz::Sort by Jan Pazdziora.

=head1 SEE ALSO

perl(1), Cz::Sort, Cz::Cstocs(3).

=head1 AUTHOR

(c) 1997--2000 Jan Pazdziora <adelton@fi.muni.cz>,
http://www.fi.muni.cz/~adelton/

at Faculty of Informatics, Masaryk University, Brno

=cut

