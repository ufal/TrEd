package Cprecode;

# Author: Petr Pajas
# E-mail: pajas@ufal.mff.cuni.cz
#
# Based on Jan Kasprzak's reencoding script cstocs:
#
#	Reencoding script, (c) Jan Kasprzak, 1994-1996. Version 3.0
#	Sun Aug  4 23:28:47 MET DST 1996
#
# Description:
# This module provide functions for convertsion between different
# character sets

use Carp;

my $inputenc = "iso-8859-2";
my $outputenc = "windows-1250";

%encodings = (
	      'iso-8859-2' => "ì¹èø¾ıáíéìúùóò»ïµà¶å¼æñÌ©ÈØ®İÁÍÉÌÚÙÓÒ«Ï¥À¦Å¬ÆÑ",
	      'ascii' => "escrzyaieeuuontdlrslzcnESCRZYAIEEUUONTDLRSLZCN",
	      'iso-8859-1' => "escrzıáíéeúuóntdlrslzcnESCRZİÁÍÉEÚUÓNTDLRSLZCN",
	      'windows-1250' => "ìšèøıáíéìúùóòï¾àœåŸæñÌŠÈØİÁÍÉÌÚÙÓÒÏ¼ÀŒÅÆÑ"
	     );

sub recode {
  if ($_[0] eq '-inputenc') {
    shift;
    $inputenc= shift;
  }
  if ($_[0] eq '-outputenc') {
    shift;
    $outputenc= shift;
  }

  return join("",@_) if ($inputenc eq $outputenc);

  my $srcenc=$encodings{$inputenc};
  my $dstenc=$encodings{$outputenc};


  $_=join "",@_;
  eval " tr/$srcenc/$dstenc/";
  return $_;
}

