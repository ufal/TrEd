package TrEd::Convert;

#
# $Revision$ '
# Time-stamp: <2002-07-03 16:08:08 pajas>
#
# Copyright (c) 2001 by Petr Pajas <pajas@matfyz.cz>
# This software covered by GPL - The General Public Licence
#

use strict;

BEGIN {
  use Exporter  ();
  use vars      qw($VERSION @ISA @EXPORT @EXPORT_OK %encodings $inputenc $outputenc $lefttoright $Ds);
  use TrEd::MinMax;
  @ISA=qw(Exporter);
  $VERSION = "0.1";

  @EXPORT = qw(&encode &decode &filename &dirname);
  @EXPORT_OK = qw($inputenc $outputenc $Ds %encodings);

  %encodings =
    (
     'iso-8859-2'   => "������������������̩�خ��������ҫϥ��Ŭ��",
     'ascii'        => "escrzyaieeuuontdlrslzcnESCRZYAIEEUUONTDLRSLZCN",
     'iso-8859-1'   => "escrz����e�u�ntdlrslzcnESCRZ����E�U�NTDLRSLZCN",
     'windows-1250' => "�������������������̊�؎��������ҍϼ��ŏ��",
     'windows-1256' => '�������������������������',
     'iso-8859-6' => '�������������������������'
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
}

sub encode {
  my @a=@_;
  return "" unless (@a);
  return join("",@a) if ($inputenc eq $outputenc);
  local $_=join "",@a;
  eval " tr/$encodings{$inputenc}/$encodings{$outputenc}/";
  return $_;
}

sub decode {
  my @a=@_;
  return "" unless (@a);
  return join("",@a) if ($inputenc eq $outputenc);

  local $_=join "",@a;
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

