package TrEd::Convert;

#
# $Revision$ '
# Time-stamp: <2001-08-01 12:40:28 pajas>
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

use strict;

BEGIN {
  use Exporter  ();
  use vars      qw($VERSION @ISA @EXPORT @EXPORT_OK %encodings $inputenc $outputenc $Ds);
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
     'windows-1250' => "ìšèøžýáíéìúùóòï¾àœåŸæñÌŠÈØŽÝÁÍÉÌÚÙÓÒÏ¼ÀŒÅÆÑ"
    );

  $inputenc="iso-8859-2";
  if ($^O eq "MSWin32") {
    $outputenc="windows-1250";
    $Ds="\\"; # how filenames and directories are separated
  } else {
    $Ds='/';
    $outputenc="iso-8859-2";
  }
}

sub encode {
  return "" unless (@_);
  return join("",@_) if ($inputenc eq $outputenc);

  local $_=join "",@_;
  eval " tr/$encodings{$inputenc}/$encodings{$outputenc}/";
  return $_;
}

sub decode {
  return "" unless (@_);
  return join("",@_) if ($inputenc eq $outputenc);

  local $_=join "",@_;
  eval " tr/$encodings{$outputenc}/$encodings{$inputenc}/";
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

