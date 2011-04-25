package TrEd::ConvertArab;
use Encode;

# arabjoin - a simple filter to render Arabic text
# \x{00A9} 1998-06-18 roman@czyborra.com
# Freeware license at http://czyborra.com/
# Latest version at http://czyborra.com/unicode/
# PostScript printout at http://czyborra.com/unicode/arabjoin.ps.gz

# This filter takes Arabic text (encoded in UTF-8 using the Unicode
# characters from the U+0600 Arabic block in logical order) as input
# and performs Arabic glyph joining on it and outputs a UTF-8 octet
# stream that is no longer logically arranged but in a visual order
# which gives readable results when formatted with a simple Unicode
# renderer like Yudit that does not handle Arabic differently yet 
# but simply outputs all glyphs in left-to-right order.

# This little script also demonstrates that Arabic rendering is not
# that complicated after all (it makes you wonder why some software
# companies are still asking hundreds of dollars from poor students
# who just want to print their Arabic texts) and that even Perl 4 can
# handle Unicode text in UTF-8 without any nifty new add-ons.

# Usage examples:

# echo "\x{0623}\x{0647}\x{0644}\x{0627}\x{064B} \x{0628}\x{0627}\x{0644}\x{0639}\x{0627}\x{0644}\x{0645}!" | arabjoin
# prints  !\x{FEE2}\x{FEDF}\x{FE8E}\x{FECC}\x{FEDF}\x{FE8E}\x{FE91} \x{064B}\x{FEFC}\x{FEEB}\x{FE83}
# which is the Arabic version of "Hello world!"

# | recode ISO-8859-6..UTF-8 | arabjoin | uniprint -f cyberbit.ttf
# prints an Arabic mail of charset=iso-8859-6-i on your printer

# | arabjoin | xviewer yudit
# delegates an Arabic UTF-8 message to a better viewer

# ftp://sunsite.unc.edu/pub/Linux/apps/editors/X/ has uniprint in yudit-1.0
# ftp://ftp.iro.umontreal.ca/pub/contrib/pinard/pretest/ has recode-3.4g
# http://czyborra.com/unicode/ has arabjoin
# http://czyborra.com/unix/ has xviewer
# http://www.bitstream.com/cyberbit.htm or
# ftp://ccic.ifcss.org/pub/software/fonts/unicode/ms-win/ or
# ftp://ftp.irdu.nus.sg/pub/language/bitstream/ has cyberbit.ttf

# This is how we do it: First we learn the presentation forms of each
# Arabic letter from the end of this script:


@data = split ' ', "

\x{0621}	\x{FE80}
\x{0622}	\x{FE81}\x{FE82}
\x{0623}	\x{FE83}\x{FE84}
\x{0624}	\x{FE85}\x{FE86}
\x{0625}	\x{FE87}\x{FE88}
\x{0626}	\x{FE89}\x{FE8A}\x{FE8C}\x{FE8B}
\x{0627}	\x{FE8D}\x{FE8E}
\x{0628}	\x{FE8F}\x{FE90}\x{FE92}\x{FE91}
\x{0629}	\x{FE93}\x{FE94}
\x{062A}	\x{FE95}\x{FE96}\x{FE98}\x{FE97}
\x{062B}	\x{FE99}\x{FE9A}\x{FE9C}\x{FE9B}
\x{062C}	\x{FE9D}\x{FE9E}\x{FEA0}\x{FE9F}
\x{062D}	\x{FEA1}\x{FEA2}\x{FEA4}\x{FEA3}
\x{062E}	\x{FEA5}\x{FEA6}\x{FEA8}\x{FEA7}
\x{062F}	\x{FEA9}\x{FEAA}
\x{0630}	\x{FEAB}\x{FEAC}
\x{0631}	\x{FEAD}\x{FEAE}
\x{0632}	\x{FEAF}\x{FEB0}
\x{0633}	\x{FEB1}\x{FEB2}\x{FEB4}\x{FEB3}
\x{0634}	\x{FEB5}\x{FEB6}\x{FEB8}\x{FEB7}
\x{0635}	\x{FEB9}\x{FEBA}\x{FEBC}\x{FEBB}
\x{0636}	\x{FEBD}\x{FEBE}\x{FEC0}\x{FEBF}
\x{0637}	\x{FEC1}\x{FEC2}\x{FEC4}\x{FEC3}
\x{0638}	\x{FEC5}\x{FEC6}\x{FEC8}\x{FEC7}
\x{0639}	\x{FEC9}\x{FECA}\x{FECC}\x{FECB}
\x{063A}	\x{FECD}\x{FECE}\x{FED0}\x{FECF}
\x{0640}	\x{0640}\x{0640}\x{0640}\x{0640}
\x{0641}	\x{FED1}\x{FED2}\x{FED4}\x{FED3}
\x{0642}	\x{FED5}\x{FED6}\x{FED8}\x{FED7}
\x{0643}	\x{FED9}\x{FEDA}\x{FEDC}\x{FEDB}
\x{0644}	\x{FEDD}\x{FEDE}\x{FEE0}\x{FEDF}
\x{0645}	\x{FEE1}\x{FEE2}\x{FEE4}\x{FEE3}
\x{0646}	\x{FEE5}\x{FEE6}\x{FEE8}\x{FEE7}
\x{0647}	\x{FEE9}\x{FEEA}\x{FEEC}\x{FEEB}
\x{0648}	\x{FEED}\x{FEEE}
\x{0649}	\x{FEEF}\x{FEF0} // \x{FBE9}\x{FBE8}
\x{064A}	\x{FEF1}\x{FEF2}\x{FEF4}\x{FEF3}
\x{0671}	\x{FB50} // \x{FB51}
\x{0672}	\x{0672}\x{0672}
\x{0673}	\x{0673}\x{0673}
\x{0674}	\x{0674}
\x{0675}	\x{0675}\x{0675}
\x{0676}	\x{0676}\x{0676}
\x{0677}	\x{FBDD}\x{0677}
\x{0678}	\x{0678}\x{0678}\x{0678}\x{0678}
\x{0679}	\x{FB66}\x{FB67}\x{FB69}\x{FB68}
\x{067A}	\x{FB5E}\x{FB5F}\x{FB61}\x{FB60}
\x{067B}	\x{FB52}\x{FB53}\x{FB55}\x{FB54}
\x{067C}	\x{067C}\x{067C}\x{067C}\x{067C}
\x{067D}	\x{067D}\x{067D}\x{067D}\x{067D}
\x{067E}	\x{FB56}\x{FB57}\x{FB59}\x{FB58}
\x{067F}	\x{FB62}\x{FB63}\x{FB65}\x{FB64}
\x{0680}	\x{FB5A}\x{FB5B}\x{FB5D}\x{FB5C}
\x{0681}	\x{0681}\x{0681}\x{0681}\x{0681}
\x{0682}	\x{0682}\x{0682}\x{0682}\x{0682}
\x{0683}	\x{FB76}\x{FB77}\x{FB79}\x{FB78}
\x{0684}	\x{FB72}\x{FB73}\x{FB75}\x{FB74}
\x{0685}	\x{0685}\x{0685}\x{0685}\x{0685}
\x{0686}	\x{FB7A}\x{FB7B}\x{FB7D}\x{FB7C}
\x{0687}	\x{FB7E}\x{FB7F}\x{FB81}\x{FB80}
\x{0688}	\x{FB88}\x{FB89}
\x{0689}	\x{0689}\x{0689}
\x{068A}	\x{068A}\x{068A}
\x{068B}	\x{068B}\x{068B}
\x{068C}	\x{FB84}\x{FB85}
\x{068D}	\x{FB82}\x{FB83}
\x{068E}	\x{FB86}\x{FB87}
\x{068F}	\x{068F}\x{068F}
\x{0690}	\x{0690}\x{0690}
\x{0691}	\x{FB8C}\x{FB8D}
\x{0692}	\x{0692}\x{0692}
\x{0693}	\x{0693}\x{0693}
\x{0694}	\x{0694}\x{0694}
\x{0695}	\x{0695}\x{0695}
\x{0696}	\x{0695}\x{0696}
\x{0697}	\x{0697}\x{0697}
\x{0698}	\x{FB8A}\x{FB8B}
\x{0699}	\x{0699}\x{0699}
\x{069A}	\x{069A}\x{069A}\x{069A}\x{069A}
\x{069B}	\x{069B}\x{069B}\x{069B}\x{069B}
\x{069C}	\x{069C}\x{069C}\x{069C}\x{069C}
\x{069D}	\x{069D}\x{069D}\x{069D}\x{069D}
\x{069E}	\x{069E}\x{069E}\x{069E}\x{069E}
\x{069F}	\x{069F}\x{069F}\x{069F}\x{069F}
\x{06A0}	\x{06A0}\x{06A0}\x{06A0}\x{06A0}
\x{06A1}	\x{06A1}\x{06A1}\x{06A1}\x{06A1}
\x{06A2}	\x{06A2}\x{06A2}\x{06A2}\x{06A2}
\x{06A3}	\x{06A3}\x{06A3}\x{06A3}\x{06A3}
\x{06A4}	\x{FB6A}\x{FB6B}\x{FB6D}\x{FB6C}
\x{06A5}	\x{06A5}\x{06A5}\x{06A5}\x{06A5}
\x{06A6}	\x{FB6E}\x{FB6F}\x{FB71}\x{FB70}
\x{06A7}	\x{06A7}\x{06A7}\x{06A7}\x{06A7}
\x{06A8}	\x{06A8}\x{06A8}\x{06A8}\x{06A8}
\x{06A9}	\x{FB8E}\x{FB8F}\x{FB91}\x{FB90}
\x{06AA}	\x{06AA}\x{06AA}\x{06AA}\x{06AA}
\x{06AB}	\x{06AB}\x{06AB}\x{06AB}\x{06AB}
\x{06AC}	\x{06AC}\x{06AC}\x{06AC}\x{06AC}
\x{06AD}	\x{FBD3}\x{FBD4}\x{FBD6}\x{FBD5}
\x{06AE}	\x{06AE}\x{06AE}\x{06AE}\x{06AE}
\x{06AF}	\x{FB92}\x{FB93}\x{FB95}\x{FB94}
\x{06B0}	\x{06B0}\x{06B0}\x{06B0}\x{06B0}
\x{06B1}	\x{FB9A}\x{FB9B}\x{FB9D}\x{FB9C}
\x{06B2}	\x{06B2}\x{06B2}\x{06B2}\x{06B2}
\x{06B3}	\x{FB96}\x{FB97}\x{FB99}\x{FB98}
\x{06B4}	\x{06B4}\x{06B4}\x{06B4}\x{06B4}
\x{06B5}	\x{06B5}\x{06B5}\x{06B5}\x{06B5}
\x{06B6}	\x{06B6}\x{06B6}\x{06B6}\x{06B6}
\x{06B7}	\x{06B7}\x{06B7}\x{06B7}\x{06B7}
\x{06BA}	\x{FB9E}\x{FB9F}\x{06BA}\x{06BA}
\x{06BB}	\x{FBA0}\x{FBA1}\x{FBA3}\x{FBA2}
\x{06BC}	\x{06BC}\x{06BC}\x{06BC}\x{06BC}
\x{06BD}	\x{06BD}\x{06BD}\x{06BD}\x{06BD}
\x{06BE}	\x{FBAA}\x{FBAB}\x{FBAD}\x{FBAC}
\x{06C0}	\x{FBA4}\x{FBA5}
\x{06C1}	\x{FBA6}\x{FBA7}\x{FBA9}\x{FBA8}
\x{06C2}	\x{06C2}\x{06C2}
\x{06C3}	\x{06C3}\x{06C3}
\x{06C4}	\x{06C4}\x{06C4}
\x{06C5}	\x{FBE0}\x{FBE1}
\x{06C6}	\x{FBD9}\x{FBDA}
\x{06C7}	\x{FBD7}\x{FBD8}
\x{06C8}	\x{FBDB}\x{FBDC}
\x{06C9}	\x{FBE2}\x{FBE3}
\x{06CA}	\x{06CA}\x{06CA}
\x{06CB}	\x{FBDE}\x{FBDF}
\x{06CC}	\x{FBFC}\x{FBFD}\x{FBFF}\x{FBFE}
\x{06CD}	\x{06CD}\x{06CD}
\x{06CE}	\x{06CE}\x{06CE}\x{06CE}\x{06CE}
\x{06D0}	\x{FBE4}\x{FBE5}\x{FBE7}\x{FBE6}
\x{06C1}	\x{06C1}\x{06C1}\x{06C1}\x{06C1}
\x{06C2}	\x{06C2}\x{06C2}
\x{06C3}	\x{06C3}\x{06C3}
\x{06C4}	\x{06C4}\x{06C4}
\x{06C5}	\x{06C5}\x{06C5}
\x{06C6}	\x{06C6}\x{06C6}
\x{06C7}	\x{06C7}\x{06C7}
\x{06C8}	\x{06C8}\x{06C8}
\x{06C9}	\x{06C9}\x{06C9}
\x{06CA}	\x{06CA}\x{06CA}
\x{06CB}	\x{06CB}\x{06CB}
\x{06CC}	\x{06CC}\x{06CC}\x{06CC}\x{06CC}
\x{06CD}	\x{06CD}\x{06CD}
\x{06CE}	\x{06CE}\x{06CE}\x{06CE}\x{06CE}
\x{06D0}	\x{06D0}\x{06D0}\x{06D0}\x{06D0}
\x{06D1}	\x{06D1}\x{06D1}\x{06D1}\x{06D1}
\x{06D2}	\x{FBAE}\x{FBAF}
\x{06D3}	\x{FBB0}\x{FBB1}
\x{06D5}	\x{06D5}
\x{200D}	\x{200D}\x{200D}\x{200D}\x{200D}

";


while (@data) {

  ($char, $_) = (shift @data, shift @data);
  ($isolated{$char}, $final{$char}, $medial{$char}, $initial{$char}) = split //, $_;
}

# Then learn the (incomplete set of) transparent characters:

foreach $char (split ' ', "

    \x{064B} \x{064C} \x{064D} \x{064E} \x{064F} \x{0650} \x{0652}
    \x{0651} \x{0670} \x{0657} \x{0656}

    \x{06D6} \x{06D7} \x{06D8} \x{06D9} \x{06DA} \x{06DB} \x{06DC}
    \x{06DF} \x{06E0} \x{06E1} \x{06E2} \x{06E3} \x{06E4} \x{06E7}
    \x{06E8} \x{06EA} \x{06EB} \x{06EC} \x{06ED} 

        ") {

    $transparent{$char} = 1;
}

sub arabjoin {   

    local $_ = $_[0];

    s/\n$//; # chop off the end of the line so it won't jump upfront

    # Finally we can process our text:

    @uchar = split //, $_;

    # We walk through the line of text and do contextual analysis:

    for ($i = $[; $i <= $#uchar; $i = $j) {

	for ($b = $uchar[$j = $i]; $transparent{$c = $uchar[++$j]}; ) { }

	# The following assignment is the heart of the algorithm.
	# It reduces the Arabic joining algorithm described on
	# pages 6-24 to 6-26 of the Arabic character block description
	# in the Unicode 2.0 Standard to four lines of Perl:

	$uchar[$i] = $a && $final{$c} && $medial{$b} 
	|| $final{$c} && $initial{$b}
	|| $a && $final{$b}
	|| $isolated{$b}
	|| $b;

	$a = $initial{$b} && $final{$c};
    }

    # Until the Unicode Consortium publishes its Unicode Technical
    # Report #9 (Bidirectional Algorithm Reference Implementation)
    # at http://www.unicode.org/unicode/reports/techreports.html
    # let us oversimplify things a bit and reverse everything:
 
    $_ = join '', @uchar;

    # The following 8 obligatory LAM+ALEF ligatures are encoded in the
    # U+FE70 Arabic Presentation Forms-B block in Unicode's
    # compatibility zone:

    s/\x{FEDF}\x{FE82}/\x{FEF5}/g;
    s/\x{FEE0}\x{FE82}/\x{FEF6}/g;
    s/\x{FEDF}\x{FE84}/\x{FEF7}/g;
    s/\x{FEE0}\x{FE84}/\x{FEF8}/g;
    s/\x{FEDF}\x{FE88}/\x{FEF9}/g;
    s/\x{FEE0}\x{FE88}/\x{FEFA}/g;
    s/\x{FEDF}\x{FE8E}/\x{FEFB}/g;
    s/\x{FEE0}\x{FE8E}/\x{FEFC}/g;

    # Bitstream's Cyberbit font offers 57 of the other 466 optional
    # ligatures in the U+FB50 Arabic Presentation Forms-A block:

    #s/\x{FE97}\x{FEE2}/\x{FC0E}/g;
    #s/\x{FED3}\x{FEF2}/\x{FC32}/g;
    #s/\x{FEDF}\x{FE9E}/\x{FC3F}/g;
    #s/\x{FEDF}\x{FEA2}/\x{FC40}/g;
    #s/\x{FEDF}\x{FEA6}/\x{FC41}/g;
    #s/\x{FEDF}\x{FEE2}/\x{FC42}/g;
    #s/\x{FEDF}\x{FEF0}/\x{FC43}/g;
    #s/\x{FEDF}\x{FEF2}/\x{FC44}/g;
    #s/\x{FEE7}\x{FEE2}/\x{FC4E}/g;
    #s/\x{0651}\x{064C}/\x{FC5E}/g;
    #s/\x{0651}\x{064D}/\x{FC5F}/g;
    #s/\x{0651}\x{064E}/\x{FC60}/g;
    #s/\x{0651}\x{064F}/\x{FC61}/g;
    #s/\x{0651}\x{0650}/\x{FC62}/g;
    #s/\x{FE92}\x{FEAE}/\x{FC6A}/g;
    #s/\x{FE92}\x{FEE6}/\x{FC6D}/g;
    #s/\x{FE92}\x{FEF2}/\x{FC6F}/g;
    #s/\x{FE98}\x{FEAE}/\x{FC70}/g;
    #s/\x{FE98}\x{FEE6}/\x{FC73}/g;
    #s/\x{FE98}\x{FEF2}/\x{FC75}/g;
    #s/\x{FEE8}\x{FEF2}/\x{FC8F}/g;
    #s/\x{FEF4}\x{FEAE}/\x{FC91}/g;
    #s/\x{FEF4}\x{FEE6}/\x{FC94}/g;
    #s/\x{FE91}\x{FEA0}/\x{FC9C}/g;
    #s/\x{FE91}\x{FEA4}/\x{FC9D}/g;
    #s/\x{FE91}\x{FEA8}/\x{FC9E}/g;
    #s/\x{FE91}\x{FEE4}/\x{FC9F}/g;
    #s/\x{FE97}\x{FEA0}/\x{FCA1}/g;
    #s/\x{FE97}\x{FEA4}/\x{FCA2}/g;
    #s/\x{FE97}\x{FEA8}/\x{FCA3}/g;
    #s/\x{FE97}\x{FEE4}/\x{FCA4}/g;
    #s/\x{FE9B}\x{FEE4}/\x{FCA6}/g;
    #s/\x{FE9F}\x{FEE4}/\x{FCA8}/g;
    #s/\x{FEA3}\x{FEE4}/\x{FCAA}/g;
    #s/\x{FEA7}\x{FEE4}/\x{FCAC}/g;
    #s/\x{FEB3}\x{FEE4}/\x{FCB0}/g;
    #s/\x{FEDF}\x{FEA0}/\x{FCC9}/g;
    #s/\x{FEDF}\x{FEA4}/\x{FCCA}/g;
    #s/\x{FEDF}\x{FEA8}/\x{FCCB}/g;
    #s/\x{FEDF}\x{FEE4}/\x{FCCC}/g;
    #s/\x{FEDF}\x{FEEC}/\x{FCCD}/g;
    #s/\x{FEE3}\x{FEA0}/\x{FCCE}/g;
    #s/\x{FEE3}\x{FEA4}/\x{FCCF}/g;
    #s/\x{FEE3}\x{FEA8}/\x{FCD0}/g;
    #s/\x{FEE3}\x{FEE4}/\x{FCD1}/g;
    #s/\x{FEE7}\x{FEA0}/\x{FCD2}/g;
    #s/\x{FEE7}\x{FEA4}/\x{FCD3}/g;
    #s/\x{FEE7}\x{FEA8}/\x{FCD4}/g;
    #s/\x{FEE7}\x{FEE4}/\x{FCD5}/g;
    #s/\x{FEF3}\x{FEA0}/\x{FCDA}/g;
    #s/\x{FEF3}\x{FEA4}/\x{FCDB}/g;
    #s/\x{FEF3}\x{FEA8}/\x{FCDC}/g;
    #s/\x{FEF3}\x{FEE4}/\x{FCDD}/g;
    #s/\x{FEDF}\x{FEE4}\x{FEA4}/\x{FD88}/g;
    #s/\x{FE8D}\x{FEDF}\x{FEE0}\x{FEEA}/\x{FDF2}/g;
    #s/\x{FEED}\x{FEB3}\x{FEE0}\x{FEE2}/\x{FECB}\x{FEE0}\x{FEF4}\x{FEEA}/g;
    #s/\x{FE9F}\x{FEE0}\x{FE8E}\x{FEDF}\x{FEEA}/\x{FE9F}\x{FEDE}/g;

    return $_;
}

1;

# The following table lists the presentation variants of each
# character.  Each value from the U+0600 block means that the
# necessary glyph variant has not been assigned a code in Unicode's
# U+FA00 compatibility zone.  You may want to insert your private
# glyphs or approximation glyphs for them:

