package Tie::AGLFN;

use Carp;

sub TIEARRAY {
  my ($class, $hash) = @_;
  return bless $hash,$class;
}

sub FETCH {
  $_[0]->{$_[1]}
}

sub STORE {}

sub FETCHSIZE {
  return scalar(keys(%{$_[0]}));
}

package PostScript::AGLFN;
use PostScript::FontMetrics;
use base qw(PostScript::FontMetrics);

use vars qw($charmap);

=pod

=head1 NAME

PostScript::AGLFN - map characters to Adobe Glyph Names

=head1 SYNOPSIS

=cut

sub get_aglfn {
  unless ($charmap) {
    $charmap = {
		map { /^([0-9a-fA-F]+) (.*)/ ? (hex($1) => $2) : () }
		grep { !/^#|^\s*$/ } <PostScript::AGLFN::DATA>
	       };
  }
  $charmap;
}

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my @ev;
  tie @ev,'Tie::AGLFN', get_aglfn();
  $self->{encodingvector} = \@ev;
  bless($self,$class);
}

sub stringwidth {
    my ($self, $string, $pt) = @_;

    my $wx = $self->CharWidthData;
    my $ev = $self->EncodingVector;
    if ( scalar(@{$self->{encodingvector}}) <= 0 ) {
	die ($self->FileName . ": Missing Encoding\n");
    }
    my $wd = 0;
    foreach ( unpack ("U*", $string)) {
	$wd += $wx->{$ev->[$_]||'.undef'};
    }

    if ( defined $pt ) {
	carp ("Using a PointSize argument to stringwidth is deprecated")
	  if $^W;
	$wd *= $pt / 1000;
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
	$wd *= $pt / 1000;
    }
    $wd;
}


sub char_name {
  return $self->{encodingvector}->[$_[0]];
}


1;


=head1 AUTHOR

Petr Pajas <pajas@matfyz.cz>

=cut


__DATA__
0041 A
00C6 AE
01FC AEacute
00C1 Aacute
0102 Abreve
00C2 Acircumflex
00C4 Adieresis
00C0 Agrave
0391 Alpha
0386 Alphatonos
0100 Amacron
0104 Aogonek
00C5 Aring
01FA Aringacute
00C3 Atilde
0042 B
0392 Beta
0043 C
0106 Cacute
010C Ccaron
00C7 Ccedilla
0108 Ccircumflex
010A Cdotaccent
03A7 Chi
0044 D
010E Dcaron
0110 Dcroat
2206 Delta
0045 E
00C9 Eacute
0114 Ebreve
011A Ecaron
00CA Ecircumflex
00CB Edieresis
0116 Edotaccent
00C8 Egrave
0112 Emacron
014A Eng
0118 Eogonek
0395 Epsilon
0388 Epsilontonos
0397 Eta
0389 Etatonos
00D0 Eth
20AC Euro
0046 F
0047 G
0393 Gamma
011E Gbreve
01E6 Gcaron
011C Gcircumflex
0122 Gcommaaccent
0120 Gdotaccent
0048 H
25CF H18533
25AA H18543
25AB H18551
25A1 H22073
0126 Hbar
0124 Hcircumflex
0049 I
0132 IJ
00CD Iacute
012C Ibreve
00CE Icircumflex
00CF Idieresis
0130 Idotaccent
2111 Ifraktur
00CC Igrave
012A Imacron
012E Iogonek
0399 Iota
03AA Iotadieresis
038A Iotatonos
0128 Itilde
004A J
0134 Jcircumflex
004B K
039A Kappa
0136 Kcommaaccent
004C L
0139 Lacute
039B Lambda
013D Lcaron
013B Lcommaaccent
013F Ldot
0141 Lslash
004D M
039C Mu
004E N
0143 Nacute
0147 Ncaron
0145 Ncommaaccent
00D1 Ntilde
039D Nu
004F O
0152 OE
00D3 Oacute
014E Obreve
00D4 Ocircumflex
00D6 Odieresis
00D2 Ograve
01A0 Ohorn
0150 Ohungarumlaut
014C Omacron
2126 Omega
038F Omegatonos
039F Omicron
038C Omicrontonos
00D8 Oslash
01FE Oslashacute
00D5 Otilde
0050 P
03A6 Phi
03A0 Pi
03A8 Psi
0051 Q
0052 R
0154 Racute
0158 Rcaron
0156 Rcommaaccent
211C Rfraktur
03A1 Rho
0053 S
250C SF010000
2514 SF020000
2510 SF030000
2518 SF040000
253C SF050000
252C SF060000
2534 SF070000
251C SF080000
2524 SF090000
2500 SF100000
2502 SF110000
2561 SF190000
2562 SF200000
2556 SF210000
2555 SF220000
2563 SF230000
2551 SF240000
2557 SF250000
255D SF260000
255C SF270000
255B SF280000
255E SF360000
255F SF370000
255A SF380000
2554 SF390000
2569 SF400000
2566 SF410000
2560 SF420000
2550 SF430000
256C SF440000
2567 SF450000
2568 SF460000
2564 SF470000
2565 SF480000
2559 SF490000
2558 SF500000
2552 SF510000
2553 SF520000
256B SF530000
256A SF540000
015A Sacute
0160 Scaron
015E Scedilla
015C Scircumflex
0218 Scommaaccent
03A3 Sigma
0054 T
03A4 Tau
0166 Tbar
0164 Tcaron
0162 Tcommaaccent
0398 Theta
00DE Thorn
0055 U
00DA Uacute
016C Ubreve
00DB Ucircumflex
00DC Udieresis
00D9 Ugrave
01AF Uhorn
0170 Uhungarumlaut
016A Umacron
0172 Uogonek
03A5 Upsilon
03D2 Upsilon1
03AB Upsilondieresis
038E Upsilontonos
016E Uring
0168 Utilde
0056 V
0057 W
1E82 Wacute
0174 Wcircumflex
1E84 Wdieresis
1E80 Wgrave
0058 X
039E Xi
0059 Y
00DD Yacute
0176 Ycircumflex
0178 Ydieresis
1EF2 Ygrave
005A Z
0179 Zacute
017D Zcaron
017B Zdotaccent
0396 Zeta
0061 a
00E1 aacute
0103 abreve
00E2 acircumflex
00B4 acute
0301 acutecomb
00E4 adieresis
00E6 ae
01FD aeacute
2015 afii00208
0410 afii10017
0411 afii10018
0412 afii10019
0413 afii10020
0414 afii10021
0415 afii10022
0401 afii10023
0416 afii10024
0417 afii10025
0418 afii10026
0419 afii10027
041A afii10028
041B afii10029
041C afii10030
041D afii10031
041E afii10032
041F afii10033
0420 afii10034
0421 afii10035
0422 afii10036
0423 afii10037
0424 afii10038
0425 afii10039
0426 afii10040
0427 afii10041
0428 afii10042
0429 afii10043
042A afii10044
042B afii10045
042C afii10046
042D afii10047
042E afii10048
042F afii10049
0490 afii10050
0402 afii10051
0403 afii10052
0404 afii10053
0405 afii10054
0406 afii10055
0407 afii10056
0408 afii10057
0409 afii10058
040A afii10059
040B afii10060
040C afii10061
040E afii10062
0430 afii10065
0431 afii10066
0432 afii10067
0433 afii10068
0434 afii10069
0435 afii10070
0451 afii10071
0436 afii10072
0437 afii10073
0438 afii10074
0439 afii10075
043A afii10076
043B afii10077
043C afii10078
043D afii10079
043E afii10080
043F afii10081
0440 afii10082
0441 afii10083
0442 afii10084
0443 afii10085
0444 afii10086
0445 afii10087
0446 afii10088
0447 afii10089
0448 afii10090
0449 afii10091
044A afii10092
044B afii10093
044C afii10094
044D afii10095
044E afii10096
044F afii10097
0491 afii10098
0452 afii10099
0453 afii10100
0454 afii10101
0455 afii10102
0456 afii10103
0457 afii10104
0458 afii10105
0459 afii10106
045A afii10107
045B afii10108
045C afii10109
045E afii10110
040F afii10145
0462 afii10146
0472 afii10147
0474 afii10148
045F afii10193
0463 afii10194
0473 afii10195
0475 afii10196
04D9 afii10846
200E afii299
200F afii300
200D afii301
066A afii57381
060C afii57388
0660 afii57392
0661 afii57393
0662 afii57394
0663 afii57395
0664 afii57396
0665 afii57397
0666 afii57398
0667 afii57399
0668 afii57400
0669 afii57401
061B afii57403
061F afii57407
0621 afii57409
0622 afii57410
0623 afii57411
0624 afii57412
0625 afii57413
0626 afii57414
0627 afii57415
0628 afii57416
0629 afii57417
062A afii57418
062B afii57419
062C afii57420
062D afii57421
062E afii57422
062F afii57423
0630 afii57424
0631 afii57425
0632 afii57426
0633 afii57427
0634 afii57428
0635 afii57429
0636 afii57430
0637 afii57431
0638 afii57432
0639 afii57433
063A afii57434
0640 afii57440
0641 afii57441
0642 afii57442
0643 afii57443
0644 afii57444
0645 afii57445
0646 afii57446
0648 afii57448
0649 afii57449
064A afii57450
064B afii57451
064C afii57452
064D afii57453
064E afii57454
064F afii57455
0650 afii57456
0651 afii57457
0652 afii57458
0647 afii57470
06A4 afii57505
067E afii57506
0686 afii57507
0698 afii57508
06AF afii57509
0679 afii57511
0688 afii57512
0691 afii57513
06BA afii57514
06D2 afii57519
06D5 afii57534
20AA afii57636
05BE afii57645
05C3 afii57658
05D0 afii57664
05D1 afii57665
05D2 afii57666
05D3 afii57667
05D4 afii57668
05D5 afii57669
05D6 afii57670
05D7 afii57671
05D8 afii57672
05D9 afii57673
05DA afii57674
05DB afii57675
05DC afii57676
05DD afii57677
05DE afii57678
05DF afii57679
05E0 afii57680
05E1 afii57681
05E2 afii57682
05E3 afii57683
05E4 afii57684
05E5 afii57685
05E6 afii57686
05E7 afii57687
05E8 afii57688
05E9 afii57689
05EA afii57690
05F0 afii57716
05F1 afii57717
05F2 afii57718
05B4 afii57793
05B5 afii57794
05B6 afii57795
05BB afii57796
05B8 afii57797
05B7 afii57798
05B0 afii57799
05B2 afii57800
05B1 afii57801
05B3 afii57802
05C2 afii57803
05C1 afii57804
05B9 afii57806
05BC afii57807
05BD afii57839
05BF afii57841
05C0 afii57842
02BC afii57929
2105 afii61248
2113 afii61289
2116 afii61352
202C afii61573
202D afii61574
202E afii61575
200C afii61664
066D afii63167
02BD afii64937
00E0 agrave
2135 aleph
03B1 alpha
03AC alphatonos
0101 amacron
0026 ampersand
2220 angle
2329 angleleft
232A angleright
0387 anoteleia
0105 aogonek
2248 approxequal
00E5 aring
01FB aringacute
2194 arrowboth
21D4 arrowdblboth
21D3 arrowdbldown
21D0 arrowdblleft
21D2 arrowdblright
21D1 arrowdblup
2193 arrowdown
2190 arrowleft
2192 arrowright
2191 arrowup
2195 arrowupdn
21A8 arrowupdnbse
005E asciicircum
007E asciitilde
002A asterisk
2217 asteriskmath
0040 at
00E3 atilde
0062 b
005C backslash
007C bar
03B2 beta
2588 block
007B braceleft
007D braceright
005B bracketleft
005D bracketright
02D8 breve
00A6 brokenbar
2022 bullet
0063 c
0107 cacute
02C7 caron
21B5 carriagereturn
010D ccaron
00E7 ccedilla
0109 ccircumflex
010B cdotaccent
00B8 cedilla
00A2 cent
03C7 chi
25CB circle
2297 circlemultiply
2295 circleplus
02C6 circumflex
2663 club
003A colon
20A1 colonmonetary
002C comma
2245 congruent
00A9 copyright
00A4 currency
0064 d
2020 dagger
2021 daggerdbl
010F dcaron
0111 dcroat
00B0 degree
03B4 delta
2666 diamond
00A8 dieresis
0385 dieresistonos
00F7 divide
2593 dkshade
2584 dnblock
0024 dollar
20AB dong
02D9 dotaccent
0323 dotbelowcomb
0131 dotlessi
22C5 dotmath
0065 e
00E9 eacute
0115 ebreve
011B ecaron
00EA ecircumflex
00EB edieresis
0117 edotaccent
00E8 egrave
0038 eight
2208 element
2026 ellipsis
0113 emacron
2014 emdash
2205 emptyset
2013 endash
014B eng
0119 eogonek
03B5 epsilon
03AD epsilontonos
003D equal
2261 equivalence
212E estimated
03B7 eta
03AE etatonos
00F0 eth
0021 exclam
203C exclamdbl
00A1 exclamdown
2203 existential
0066 f
2640 female
2012 figuredash
25A0 filledbox
25AC filledrect
0035 five
215D fiveeighths
0192 florin
0034 four
2044 fraction
20A3 franc
0067 g
03B3 gamma
011F gbreve
01E7 gcaron
011D gcircumflex
0123 gcommaaccent
0121 gdotaccent
00DF germandbls
2207 gradient
0060 grave
0300 gravecomb
003E greater
2265 greaterequal
00AB guillemotleft
00BB guillemotright
2039 guilsinglleft
203A guilsinglright
0068 h
0127 hbar
0125 hcircumflex
2665 heart
0309 hookabovecomb
2302 house
02DD hungarumlaut
002D hyphen
0069 i
00ED iacute
012D ibreve
00EE icircumflex
00EF idieresis
00EC igrave
0133 ij
012B imacron
221E infinity
222B integral
2321 integralbt
2320 integraltp
2229 intersection
25D8 invbullet
25D9 invcircle
263B invsmileface
012F iogonek
03B9 iota
03CA iotadieresis
0390 iotadieresistonos
03AF iotatonos
0129 itilde
006A j
0135 jcircumflex
006B k
03BA kappa
0137 kcommaaccent
0138 kgreenlandic
006C l
013A lacute
03BB lambda
013E lcaron
013C lcommaaccent
0140 ldot
003C less
2264 lessequal
258C lfblock
20A4 lira
2227 logicaland
00AC logicalnot
2228 logicalor
017F longs
25CA lozenge
0142 lslash
2591 ltshade
006D m
00AF macron
2642 male
2212 minus
2032 minute
00B5 mu
00D7 multiply
266A musicalnote
266B musicalnotedbl
006E n
0144 nacute
0149 napostrophe
0148 ncaron
0146 ncommaaccent
0039 nine
2209 notelement
2260 notequal
2284 notsubset
00F1 ntilde
03BD nu
0023 numbersign
006F o
00F3 oacute
014F obreve
00F4 ocircumflex
00F6 odieresis
0153 oe
02DB ogonek
00F2 ograve
01A1 ohorn
0151 ohungarumlaut
014D omacron
03C9 omega
03D6 omega1
03CE omegatonos
03BF omicron
03CC omicrontonos
0031 one
2024 onedotenleader
215B oneeighth
00BD onehalf
00BC onequarter
2153 onethird
25E6 openbullet
00AA ordfeminine
00BA ordmasculine
221F orthogonal
00F8 oslash
01FF oslashacute
00F5 otilde
0070 p
00B6 paragraph
0028 parenleft
0029 parenright
2202 partialdiff
0025 percent
002E period
00B7 periodcentered
22A5 perpendicular
2030 perthousand
20A7 peseta
03C6 phi
03D5 phi1
03C0 pi
002B plus
00B1 plusminus
211E prescription
220F product
2282 propersubset
2283 propersuperset
221D proportional
03C8 psi
0071 q
003F question
00BF questiondown
0022 quotedbl
201E quotedblbase
201C quotedblleft
201D quotedblright
2018 quoteleft
201B quotereversed
2019 quoteright
201A quotesinglbase
0027 quotesingle
0072 r
0155 racute
221A radical
0159 rcaron
0157 rcommaaccent
2286 reflexsubset
2287 reflexsuperset
00AE registered
2310 revlogicalnot
03C1 rho
02DA ring
2590 rtblock
0073 s
015B sacute
0161 scaron
015F scedilla
015D scircumflex
0219 scommaaccent
2033 second
00A7 section
003B semicolon
0037 seven
215E seveneighths
2592 shade
03C3 sigma
03C2 sigma1
223C similar
0036 six
002F slash
263A smileface
0020 space
2660 spade
00A3 sterling
220B suchthat
2211 summation
263C sun
0074 t
03C4 tau
0167 tbar
0165 tcaron
0163 tcommaaccent
2234 therefore
03B8 theta
03D1 theta1
00FE thorn
0033 three
215C threeeighths
00BE threequarters
02DC tilde
0303 tildecomb
0384 tonos
2122 trademark
25BC triagdn
25C4 triaglf
25BA triagrt
25B2 triagup
0032 two
2025 twodotenleader
2154 twothirds
0075 u
00FA uacute
016D ubreve
00FB ucircumflex
00FC udieresis
00F9 ugrave
01B0 uhorn
0171 uhungarumlaut
016B umacron
005F underscore
2017 underscoredbl
222A union
2200 universal
0173 uogonek
2580 upblock
03C5 upsilon
03CB upsilondieresis
03B0 upsilondieresistonos
03CD upsilontonos
016F uring
0169 utilde
0076 v
0077 w
1E83 wacute
0175 wcircumflex
1E85 wdieresis
2118 weierstrass
1E81 wgrave
0078 x
03BE xi
0079 y
00FD yacute
0177 ycircumflex
00FF ydieresis
00A5 yen
1EF3 ygrave
007A z
017A zacute
017E zcaron
017C zdotaccent
0030 zero
03B6 zeta
0077 w
1E83 wacute
0175 wcircumflex
1E85 wdieresis
2118 weierstrass
1E81 wgrave
0078 x
03BE xi
0079 y
00FD yacute
0177 ycircumflex
00FF ydieresis
00A5 yen
1EF3 ygrave
007A z
017A zacute
017E zcaron
017C zdotaccent
0030 zero
03B6 zeta
