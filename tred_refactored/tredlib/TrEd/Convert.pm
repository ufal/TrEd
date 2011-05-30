package TrEd::Convert;

#
# $Revision: 4205 $ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#
use strict;
use warnings;


BEGIN {
  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %encodings $inputenc
              $outputenc $lefttoright $Ds $support_unicode $FORCE_REMIX $FORCE_NO_REMIX $needs_arabic_remix_re);
  use TrEd::MinMax;
  use base qw(Exporter);
  $VERSION = "0.2";

  @EXPORT = qw(&encode &decode &filename &dirname);
  @EXPORT_OK = qw($inputenc $outputenc $Ds %encodings);

  %encodings =
    (
     'iso-8859-2'   => "ì¹èø¾ýáíéìúùóò»ïµà¶å¼æñÌ©ÈØ®ÝÁÍÉÌÚÙÓÒ«Ï¥À¦Å¬ÆÑ",
     'ascii'        => "escrzyaieeuuontdlrslzcnESCRZYAIEEUUONTDLRSLZCN",
     'iso-8859-1'   => "escrzýáíéeúuóntdlrslzcnESCRZÝÁÍÉEÚUÓNTDLRSLZCN",
     'windows-1250' => "ìšèøžýáíéìúùóòï¾àœåŸæñÌŠÈØŽÝÁÍÉÌÚÙÓÒÏ¼ÀŒÅÆÑ",
     'windows-1256' => '¡ºØÙÚÛÜÝÞßáãäåæìíðñòóõöøú',
     'iso-8859-6' => '¬»×ØÙÚàáâãäåæçèéêëìíîïðñò'
    );

  if (not defined($lefttoright)) {
    $lefttoright = 1;
  }
  if (not defined($inputenc)) {
    $inputenc = "UTF-8";
  }

  if ($^O eq "MSWin32") {
    if (not defined($outputenc)) {
      $outputenc="windows-1250";
    }
    $Ds="\\"; # how filenames and directories are separated
  } 
  else {
    $Ds='/';
    $outputenc="iso-8859-2" unless defined($outputenc);
  }
  $support_unicode = ($Tk::VERSION ge 804.00);
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
#TODO: tests
sub encode {
  my $str = join(q{}, map { defined $_ ? $_ : q{} } @_);
  if ($support_unicode) { # we've got support for UNICODE in perl5.8/Tk8004
    if (($FORCE_REMIX or $^O ne 'MSWin32')
	  and
	not $FORCE_NO_REMIX
	#  and
	# ( $inputenc =~ /^utf-?8$/i or
        #   $inputenc eq 'iso-8859-6' or
        #   $inputenc eq 'windows-1256' )
	 ) {
      if ($str =~ $needs_arabic_remix_re) {
        #TODO: fully qualified names? These two functions with FQN wouldn't exist if $support_unicode wasn't true, so
        # what is the benefit of modifying glob?
        $str = remix(arabjoin($str));
      }
    }
  } 
  elsif ($]>=5.008) {
    eval "use Encode (); \$str=Encode::encode(\$outputenc,\$str);";
  } 
  else {
    eval "tr/$encodings{$inputenc}/$encodings{$outputenc}/" unless ($inputenc eq $outputenc);
  }
#  $lefttoright or ($str=~s{([^[:ascii:]]+)}{reverse $1}eg);
  if (!$lefttoright) {
    $str =~ s{([^[:ascii:]]+)}{reverse $1}eg
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
#  $lefttoright or ($str=~s{([^[:ascii:]]+)}{reverse $1}eg);
  if(!$lefttoright) {
    $str =~ s{([^[:ascii:]]+)}{reverse $1}eg;
  }
  if ($support_unicode) {
    return $str;
  } 
  elsif ($]>=5.008) {
    eval "use Encode (); \$str=Encode::decode(\$outputenc,\$str);";
    return $str;
  } 
  elsif ($inputenc eq $outputenc) {
    return $str;
  } 
  else {
    eval " tr/$encodings{$outputenc}/$encodings{$inputenc}/";
    return $str;
  }
}

#TODO: Do these function really belong here? What do they have in common with converting..?

#######################################################################################
# Usage         : dirname($path)
# Purpose       : Find out the name of the directory of $path
# Returns       : Part of the string from the first character to the last forward/backward slash
# Parameters    : scalar $path -- path whose dirname we are looking for
# Throws        : 
# Comments      : If $path does not contain any slash (fw or bw), dot and directory separator is returned, i. e. 
#                 "./" on Unices, ".\" on Win32
# See Also      : index(), rindex(), substr()
#TODO: stil needed? or can we use File::Spec instead?
# do we still support Perl 5.5?
sub dirname {
  my $a = shift;
  # this is for the sh*tty winz where
  # both slash and backslash may be uzed
  # (i'd sure use File::Spec::Functions had it support
  # for this also in 5.005 perl distro).
  return (index($a, $Ds) + index($a, q{/}) >= 0) ?
          substr($a, 0, TrEd::MinMax::max(rindex($a, $Ds), rindex($a, q{/})) + 1) : ".$Ds";
}

#######################################################################################
# Usage         : filename($path)
# Purpose       : Extract filename from $path
# Returns       : Part of the string after the last slash
# Parameters    : scalar $path -- path with file name
# Throws        : 
# Comments      : E.g. returns 'filename' from '/home/john/docs/filename'
# See Also      : index(), rindex(), substr()
#TODO: still needed? Same as with dirname, maybe we could use File::Spec...
sub filename {
  my $a = shift;
  # this is for the sh*tty winz where
  # both slash and backslash may be uzed
  return (index($a, $Ds) + index($a, q{/}) >= 0) ?
          substr($a, TrEd::MinMax::max(rindex($a, $Ds), rindex($a, q{/})) + 1) : $a;
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
  
  my $str = "¾luøouèký kùò úpìl ïábelské ódy";
  my $internal_string = TrEd::Convert::decode($str);
  
  my $iso_8859_2_str = TrEd::Convert::encode($internal_string);  
  
  my $path = "/etc/X11/xorg.conf";
  
  my $dir = TrEd::Convert::dirname($path);
  

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


=item * C<TrEd::Convert::dirname($path)>

=over 6

=item Purpose

Find out the name of the directory of $path


=item Parameters

  C<$path> -- scalar $path -- path whose dirname we are looking for

=item Comments

If $path does not contain any slash (fw or bw), dot and directory separator is returned, i. e. 

"./" on Unices, ".\" on Win32

=item See Also

L<index>,
L<rindex>,
L<substr>,

=item Returns

Part of the string from the first character to the last forward/backward slash


=back


=item * C<TrEd::Convert::filename($path)>

=over 6

=item Purpose

Extract filename from $path


=item Parameters

  C<$path> -- scalar $path -- path with file name

=item Comments

E.g. returns 'filename' from '/home/john/docs/filename'


=item See Also

L<index>,
L<rindex>,
L<substr>,

=item Returns

Part of the string after the last slash


=back




=back


=head1 DIAGNOSTICS


=head1 CONFIGURATION AND ENVIRONMENT


=head1 DEPENDENCIES

Encode, TrEd::ArabicRemix, TrEd::ConvertArab, TrEd::MinMax

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
