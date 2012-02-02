package TrEd::Convert;

#
# $Revision: 4205 $ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#
use strict;
use warnings;

use TrEd::Utils qw{$EMPTY_STR};

BEGIN {
    use Exporter  ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %encodings $inputenc
                $outputenc $lefttoright $support_unicode
                $FORCE_REMIX $FORCE_NO_REMIX $needs_arabic_remix_re);

    use base qw(Exporter);
    $VERSION = "0.2";

    @EXPORT = qw(&encode &decode);
    @EXPORT_OK = qw($inputenc $outputenc %encodings);

    %encodings =
    (
     'iso-8859-2'   => "ì¹èø¾ýáíéìúùóò»ïµà¶å¼æñÌ©ÈØ®ÝÁÍÉÌÚÙÓÒ«Ï¥À¦Å¬ÆÑ",
     'ascii'        => "escrzyaieeuuontdlrslzcnESCRZYAIEEUUONTDLRSLZCN",
     'iso-8859-1'   => "escrzýáíéeúuóntdlrslzcnESCRZÝÁÍÉEÚUÓNTDLRSLZCN",
     'windows-1250' => "ìšèøžýáíéìúùóòï¾àœåŸæñÌŠÈØŽÝÁÍÉÌÚÙÓÒÏ¼ÀŒÅÆÑ",
     'windows-1256' => '¡ºØÙÚÛÜÝÞßáãäåæìíðñòóõöøú',
     'iso-8859-6' => '¬»×ØÙÚàáâãäåæçèéêëìíîïðñò'
    );

    if ( !defined $lefttoright ) {
        $lefttoright = 1;
    }
    if ( !defined $inputenc ) {
        $inputenc = "UTF-8";
    }

    if ($^O eq "MSWin32") {
        if ( !defined $outputenc ) {
            $outputenc="windows-1250";
        }
    }
    else {
        if ( !defined $outputenc ) {
            # if text will be unreadable under some special circumstances
            # maybe set outputenc back to iso-8859-2
            # still not sure which one is better
            # $outputenc="iso-10646-1";
            $outputenc="iso-8859-2";
        }
    }
    
    $support_unicode = (defined $Tk::VERSION && $Tk::VERSION ge 804.00);
    if ($support_unicode) {
        require TrEd::ConvertArab;
        require TrEd::ArabicRemix;
        *remix = \&TrEd::ArabicRemix::remix;
        *arabjoin = \&TrEd::ConvertArab::arabjoin;
        eval q(
          $needs_arabic_remix_re=qr{\p{Arabic}|[\x{064B}-\x{0652}\x{0670}\x{0657}\x{0656}\x{0640}]|\p{InArabicPresentationFormsA}|\p{InArabicPresentationFormsB}};
        );
        die $@ if $@;
    }
}

no integer;

#######################################################################################
# Usage         : encode(@strings)
# Purpose       : Change all the strings from Perl's internal representation into $outputenc
#                 and return them joined in one string
# Returns       : Encoded string (sequence of octets)
# Parameters    : string $str (or a list of strings) to encode
# Throws        : no exception
# Comments      : This function is affected by setting $FORCE_REMIX and $FORCE_NO_REMIX variables.
#                 If $FORCE_REMIX is set or current platform is MS Win32 and $string needs arabic remix,
#                 we use functions for arabic text, unless $FORCE_NO_REMIX is not set to true.
#                 On Perl version greater than or equal to 5.8, Encode::encode() is used. Otherwise, tr/// is used.
# See Also      : Encode::encode(), tr(), TrEd::ConvertArab::arabjoin(), TrEd::ArabicRemix::remix()
sub encode {
    my $str = join( q{}, map { defined $_ ? $_ : q{} } @_ );
    if ($support_unicode) {  # we've got support for UNICODE in perl5.8/Tk8004
        if ( ( $FORCE_REMIX || $^O ne 'MSWin32' )
            && !$FORCE_NO_REMIX )
        {
            if ( $str =~ $needs_arabic_remix_re ) {

                # TODO: fully qualified names? These two functions with FQN
                # wouldn't exist if $support_unicode wasn't true, so
                # what is the benefit of modifying glob?
                $str = remix( arabjoin($str) );
            }
        }
    }
    elsif ( $] >= 5.008 ) {
        eval "use Encode (); \$str=Encode::encode(\$outputenc,\$str);";
    }
    else {
        if ( $inputenc ne $outputenc ) {
            no warnings 'misc';
            # otherwise Perl 5.12 warns that
            # 'Replacement list is longer than search list'
            # This warning appears because the length of variables differ,
            # not that the actual replacement strings have different length

            # This warning could also be fixed by renaming shorter variable
            # to match the length of name of the longer one, i.e.
            # my $inputenc_ = $inputenc;
            # and then
            # tr/$encodings{$inputenc_}/$encodings{$outputenc}/

            eval {
                tr/$encodings{$inputenc}/$encodings{$outputenc}/
            };
        }
    }
    if ( !$lefttoright ) {
        $str =~ s{([^[:ascii:]]+)}{reverse $1}eg;
    }
    return $str;
}

#######################################################################################
# Usage         : decode($str)
# Purpose       : Decodes sequence of octets from $outputenc to Perl's internal representation
#                 or $inputenc
# Returns       : Decoded string
# Parameters    : string $str (or list of strings) to decode
# Throws        : no exception
# Comments      : If the Tk version used is greater than 804.00, or $input and $output encoding are the same,
#                 function just returns joined strings. Otherwise it uses Encode::decode with Perl >= 5.8
#                 or tr for Perl < 5.8
# See Also      : Encode::decode(), tr(),
sub decode {
    my $str = join q{}, @_;

    if ( !$lefttoright ) {
        $str =~ s{([^[:ascii:]]+)}{reverse $1}eg;
    }
    if ($support_unicode) {
        return $str;
    }
    elsif ( $] >= 5.008 ) {
        eval "use Encode (); \$str=Encode::decode(\$outputenc,\$str);";
        return $str;
    }
    elsif ( $inputenc eq $outputenc ) {
        return $str;
    }
    else {
        eval {
            tr/$encodings{$outputenc}/$encodings{$inputenc}/
        };
        return $str;
    }
}


1;

__END__


=head1 NAME


TrEd::Convert - Basic functions for converting between input and output encodings


=head1 VERSION

This documentation refers to
TrEd::Convert version 0.2.


=head1 SYNOPSIS

  use TrEd::Convert;

  my $str = "¾lu»ouèký kùò úpìl ïábelské ódy";
  my $internal_string = TrEd::Convert::decode($str);

  my $iso_8859_2_str = TrEd::Convert::encode($internal_string);



=head1 DESCRIPTION


=head1 SUBROUTINES/METHODS

=over 4


=item * C<TrEd::Convert::encode(@strings)>

=over 6

=item Purpose

Change all the strings from Perl's internal representation into $outputenc

and return them joined in one string

=item Parameters

  C<@strings> -- string $str (or a list of strings) to encode

=item Comments

This function is affected by setting $FORCE_REMIX and $FORCE_NO_REMIX variables.

If $FORCE_REMIX is set or current platform is MS Win32 and $string needs arabic remix,
we use functions for arabic text, unless $FORCE_NO_REMIX is not set to true.
On Perl version greater than or equal to 5.8, Encode::encode() is used. Otherwise, tr/// is used.

=item See Also

L<Encode::encode>,
L<tr>,
L<TrEd::ConvertArab::arabjoin>,
L<TrEd::ArabicRemix::remix>,

=item Returns

Encoded string (sequence of octets)


=back


=item * C<TrEd::Convert::decode($str)>

=over 6

=item Purpose

Decodes sequence of octets from $outputenc to Perl's internal representation

or $inputenc

=item Parameters

  C<$str> -- string $str (or list of strings) to decode

=item Comments

If the Tk version used is greater than 804.00, or $input and $output encoding are the same,

function just returns joined strings. Otherwise it uses Encode::decode with Perl >= 5.8
or tr for Perl < 5.8

=item See Also

L<Encode::decode>,
L<tr>,

=item Returns

Decoded string


=back



=back


=head1 DIAGNOSTICS

If the pre-compiation of $needs_arabic_remix regular expression fails,
compilation of this module fails with error message describing the error.

=head1 CONFIGURATION AND ENVIRONMENT

This module does not require special configuration or enviroment settings.

=head1 DEPENDENCIES

Encode, TrEd::ArabicRemix, TrEd::ConvertArab

=head1 INCOMPATIBILITIES

Names of encode and decode functions collide with Encode module functions.

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
