package TrEd::Convert;

#
# $Revision$ '
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#
use strict;
use English;
#use TrEd::ConvertArab;


BEGIN {
  use Exporter  ();
  use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %encodings $inputenc
	      $outputenc $lefttoright $Ds $support_unicode);
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
  $inputenc="iso-8859-2" unless defined($inputenc);
  if ($^O eq "MSWin32") {
    $outputenc="windows-1250" unless defined($outputenc);
    $Ds="\\"; # how filenames and directories are separated
  } else {
    $Ds='/';
    $outputenc="iso-8859-2" unless defined($outputenc);
  }
  $support_unicode = ($Tk::VERSION ge 804.00);
}

sub encode {
  local $_=join '',@_;
  $lefttoright or (s{([^[:ascii:]]+)}{reverse $1}eg);
  no integer;
  if ($support_unicode) { # we've got support for UNICODE in
    # perl5.8/Tk8004
    if ($inputenc eq 'iso-8859-6' or $inputenc =~ /^utf-?8$/i or $inputenc eq 'windows-1256') {
      require TrEd::ConvertArab;
      require TrEd::ArabicRemix;
      eval "use Encode (); \$_=Encode::decode('utf8',\$_) unless Encode::is_utf8(\$_);";
      s{((?:\p{Arabic}|\p{InArabic}|\p{InArabicPresentationFormsA}|\p{InArabicPresentationFormsB}|\s)+)}{ TrEd::ConvertArab::arabjoin($1)}eg;
      $_ = TrEd::ArabicRemix::remix($_);
    }
    return $_;
  } elsif ($]>=5.008) {
    eval "use Encode (); \$_=Encode::encode(\$outputenc,\$_);";
    return $_;
  } else {
    return $_ if ($inputenc eq $outputenc);
    eval " tr/$encodings{$inputenc}/$encodings{$outputenc}/";
    return $_;
  }
}

sub decode {
  local $_=join '',@_;
  $lefttoright or (s{([^[:ascii:]]+)}{reverse $1}eg);
  no integer;
  if ($support_unicode) {
    return $_;
  } elsif ($]>=5.008) {
    eval "use Encode (); \$_=Encode::decode(\$outputenc,\$_);";
    return $_;
  } elsif ($inputenc eq $outputenc) {
    return $_;
  } else {
    eval " tr/$encodings{$outputenc}/$encodings{$inputenc}/";
  }
  return $_;
}

sub dirname {
  my $a=shift;
  # this is for the sh*tty winz where
  # both slash and backslash may be uzed
  # (i'd sure use File::Spec::Functions had it support
  # for this also in 5.005 perl distro).
  return (index($a,$Ds)+index($a,'/')>=0)? substr($a,0,
				    max(rindex($a,$Ds),
					rindex($a,'/'))+1) : ".$Ds";
}

sub filename {
  my $a=shift;
  # this is for the sh*tty winz where
  # both slash and backslash may be uzed
  return (index($a,$Ds)+index($a,'/')>=0)? 
    substr($a,max(rindex($a,$Ds),
		  rindex($a,'/'))+1) : $a;
}

1;

