package TrEd::Convert;

#
# $Revision$ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#
use strict;
#use TrEd::ConvertArab;


BEGIN {
  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %encodings $inputenc
              $outputenc $lefttoright $Ds $support_unicode $FORCE_REMIX $FORCE_NO_REMIX $needs_arabic_remix_re);
  use TrEd::MinMax;
  @ISA=qw(Exporter);
  $VERSION = "0.1";

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

  $lefttoright=1 unless defined($lefttoright);
  $inputenc="UTF-8" unless defined($inputenc);

  if ($^O eq "MSWin32") {
    $outputenc="windows-1250" unless defined($outputenc);
    $Ds="\\"; # how filenames and directories are separated
  } else {
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

sub encode {
  my $str = join '', @_;
  if ($support_unicode) { # we've got support for UNICODE in perl5.8/Tk8004
    if (($FORCE_REMIX or $^O ne 'MSWin32')
	  and
	!$FORCE_NO_REMIX
	#  and
	# ( $inputenc =~ /^utf-?8$/i or
        #   $inputenc eq 'iso-8859-6' or
        #   $inputenc eq 'windows-1256' )
	 ) {
      if ($str=~$needs_arabic_remix_re) {
	$str = remix(arabjoin($str));
      }
    }
  } elsif ($]>=5.008) {
    eval "use Encode (); \$str=Encode::encode(\$outputenc,\$str);";
  } else {
    eval "tr/$encodings{$inputenc}/$encodings{$outputenc}/" unless ($inputenc eq $outputenc);
  }
  $lefttoright or ($str=~s{([^[:ascii:]]+)}{reverse $1}eg);
  return $str;
}

sub decode {
  my $str = join '', @_;
  $lefttoright or ($str=~s{([^[:ascii:]]+)}{reverse $1}eg);
  if ($support_unicode) {
    return $str;
  } elsif ($]>=5.008) {
    eval "use Encode (); \$str=Encode::decode(\$outputenc,\$str);";
    return $str;
  } elsif ($inputenc eq $outputenc) {
    return $str;
  } else {
    eval " tr/$encodings{$outputenc}/$encodings{$inputenc}/";
    return $str;
  }
}

sub dirname {
  my $a=shift;
  # this is for the sh*tty winz where
  # both slash and backslash may be uzed
  # (i'd sure use File::Spec::Functions had it support
  # for this also in 5.005 perl distro).
  return (index($a,$Ds)+index($a,'/')>=0) ?
          substr($a,0,max(rindex($a,$Ds),rindex($a,'/'))+1) : ".$Ds";
}

sub filename {
  my $a=shift;
  # this is for the sh*tty winz where
  # both slash and backslash may be uzed
  return (index($a,$Ds)+index($a,'/')>=0) ?
          substr($a,max(rindex($a,$Ds),rindex($a,'/'))+1) : $a;
}

1;

