package TrEd::ConvertArab;
use bytes;
no encoding;
use Encode;

# arabjoin - a simple filter to render Arabic text
# © 1998-06-18 roman@czyborra.com
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

# echo "أهلاً بالعالم!" | arabjoin
# prints  !ﻢﻟﺎﻌﻟﺎﺑ ًﻼﻫﺃ
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


@data=qw(
ء	ﺀ
آ	ﺁﺂ
أ	ﺃﺄ
ؤ	ﺅﺆ
إ	ﺇﺈ
ئ	ﺉﺊﺌﺋ
ا	ﺍﺎ
ب	ﺏﺐﺒﺑ
ة	ﺓﺔ
ت	ﺕﺖﺘﺗ
ث	ﺙﺚﺜﺛ
ج	ﺝﺞﺠﺟ
ح	ﺡﺢﺤﺣ
خ	ﺥﺦﺨﺧ
د	ﺩﺪ
ذ	ﺫﺬ
ر	ﺭﺮ
ز	ﺯﺰ
س	ﺱﺲﺴﺳ
ش	ﺵﺶﺸﺷ
ص	ﺹﺺﺼﺻ
ض	ﺽﺾﻀﺿ
ط	ﻁﻂﻄﻃ
ظ	ﻅﻆﻈﻇ
ع	ﻉﻊﻌﻋ
غ	ﻍﻎﻐﻏ
ـ	ــــ
ف	ﻑﻒﻔﻓ
ق	ﻕﻖﻘﻗ
ك	ﻙﻚﻜﻛ
ل	ﻝﻞﻠﻟ
م	ﻡﻢﻤﻣ
ن	ﻥﻦﻨﻧ
ه	ﻩﻪﻬﻫ
و	ﻭﻮ
ى	ﻯﻰ // ﯩﯨ
ي	ﻱﻲﻴﻳ
ٱ	ﭐ // ﭑ
ٲ	ٲٲ
ٳ	ٳٳ
ٴ	ٴ
ٵ	ٵٵ
ٶ	ٶٶ
ٷ	ﯝٷ
ٸ	ٸٸٸٸ
ٹ	ﭦﭧﭩﭨ
ٺ	ﭞﭟﭡﭠ
ٻ	ﭒﭓﭕﭔ
ټ	ټټټټ
ٽ	ٽٽٽٽ
پ	ﭖﭗﭙﭘ
ٿ	ﭢﭣﭥﭤ
ڀ	ﭚﭛﭝﭜ
ځ	ځځځځ
ڂ	ڂڂڂڂ
ڃ	ﭶﭷﭹﭸ
ڄ	ﭲﭳﭵﭴ
څ	څڅڅڅ
چ	ﭺﭻﭽﭼ
ڇ	ﭾﭿﮁﮀ
ڈ	ﮈﮉ
ډ	ډډ
ڊ	ڊڊ
ڋ	ڋڋ
ڌ	ﮄﮅ
ڍ	ﮂﮃ
ڎ	ﮆﮇ
ڏ	ڏڏ
ڐ	ڐڐ
ڑ	ﮌﮍ
ڒ	ڒڒ
ړ	ړړ
ڔ	ڔڔ
ڕ	ڕڕ
ږ	ڕږ
ڗ	ڗڗ
ژ	ﮊﮋ
ڙ	ڙڙ
ښ	ښښښښ
ڛ	ڛڛڛڛ
ڜ	ڜڜڜڜ
ڝ	ڝڝڝڝ
ڞ	ڞڞڞڞ
ڟ	ڟڟڟڟ
ڠ	ڠڠڠڠ
ڡ	ڡڡڡڡ
ڢ	ڢڢڢڢ
ڣ	ڣڣڣڣ
ڤ	ﭪﭫﭭﭬ
ڥ	ڥڥڥڥ
ڦ	ﭮﭯﭱﭰ
ڧ	ڧڧڧڧ
ڨ	ڨڨڨڨ
ک	ﮎﮏﮑﮐ
ڪ	ڪڪڪڪ
ګ	ګګګګ
ڬ	ڬڬڬڬ
ڭ	ﯓﯔﯖﯕ
ڮ	ڮڮڮڮ
گ	ﮒﮓﮕﮔ
ڰ	ڰڰڰڰ
ڱ	ﮚﮛﮝﮜ
ڲ	ڲڲڲڲ
ڳ	ﮖﮗﮙﮘ
ڴ	ڴڴڴڴ
ڵ	ڵڵڵڵ
ڶ	ڶڶڶڶ
ڷ	ڷڷڷڷ
ں	ﮞﮟںں
ڻ	ﮠﮡﮣﮢ
ڼ	ڼڼڼڼ
ڽ	ڽڽڽڽ
ھ	ﮪﮫﮭﮬ
ۀ	ﮤﮥ
ہ	ﮦﮧﮩﮨ
ۂ	ۂۂ
ۃ	ۃۃ
ۄ	ۄۄ
ۅ	ﯠﯡ
ۆ	ﯙﯚ
ۇ	ﯗﯘ
ۈ	ﯛﯜ
ۉ	ﯢﯣ
ۊ	ۊۊ
ۋ	ﯞﯟ
ی	ﯼﯽﯿﯾ
ۍ	ۍۍ
ێ	ێێێێ
ې	ﯤﯥﯧﯦ
ہ	ہہہہ
ۂ	ۂۂ
ۃ	ۃۃ
ۄ	ۄۄ
ۅ	ۅۅ
ۆ	ۆۆ
ۇ	ۇۇ
ۈ	ۈۈ
ۉ	ۉۉ
ۊ	ۊۊ
ۋ	ۋۋ
ی	یییی
ۍ	ۍۍ
ێ	ێێێێ
ې	ېېېې
ۑ	ۑۑۑۑ
ے	ﮮﮯ
ۓ	ﮰﮱ
ە	ە
‍	‍‍‍‍);


while (@data) {
  ($char, $_) = (shift(@data),shift(@data));
  ($isolated{$char},$final{$char},$medial{$char},$initial{$char}) =
    /([\xC0-\xFF][\x80-\xBF]+)/g;
}

# Then learn the (incomplete set of) transparent characters:

foreach $char (split (" ", "
 ً ٌ ٍ َ ُ ِ ٰ
 ۗ ۘ ۙ ۚ ۛ ۜ ۟ ۠ ۡ ۢ ۣ ۤ ۧ ۨ ۪ ۫ ۬ ۭ"))
{
    $transparent{$char}=1;
}

sub arabjoin {
# Finally we can process our text:
    $_=encode('utf8',$_[0]);

    s/\n$//; # chop off the end of the line so it won't jump upfront

    @uchar = # UTF-8 character chunks
	/([\x00-\x7F]|[\xC0-\xFF][\x80-\xBF]+)/g;

    # We walk through the line of text and do contextual analysis:

    for ($i = $[; $i <= $#uchar; $i = $j)
    {
	for ($b=$uchar[$j=$i]; $transparent{$c=$uchar[++$j]};){};

	# The following assignment is the heart of the algorithm.
	# It reduces the Arabic joining algorithm described on
	# pages 6-24 to 6-26 of the Arabic character block description
	# in the Unicode 2.0 Standard to four lines of Perl:

	$uchar[$i] =  $a && $final{$c} && $medial{$b} 
	||  $final{$c} && $initial{$b}
	||  $a && $final{$b}
	||  $isolated{$b}
	||  $b;

	$a = $initial{$b} && $final{$c};
    }

    # Until the Unicode Consortium publishes its Unicode Technical
    # Report #9 (Bidirectional Algorithm Reference Implementation)
    # at http://www.unicode.org/unicode/reports/techreports.html
    # let us oversimplify things a bit and reverse everything:
 
    $_= join ('', reverse @uchar);

    # The following 8 obligatory LAM+ALEF ligatures are encoded in the
    # U+FE70 Arabic Presentation Forms-B block in Unicode's
    # compatibility zone:

    s/ﺂﻟ/ﻵ/g;
    s/ﺂﻠ/ﻶ/g;
    s/ﺄﻟ/ﻷ/g;
    s/ﺄﻠ/ﻸ/g;
    s/ﺈﻟ/ﻹ/g;
    s/ﺈﻠ/ﻺ/g;
    s/ﺎﻟ/ﻻ/g;
    s/ﺎﻠ/ﻼ/g;

    # Bitstream's Cyberbit font offers 57 of the other 466 optional
    # ligatures in the U+FB50 Arabic Presentation Forms-A block:

    s/ﻢﺗ/ﰎ/g;
    s/ﻲﻓ/ﰲ/g;
    s/ﺞﻟ/ﰿ/g;
    s/ﺢﻟ/ﱀ/g;
    s/ﺦﻟ/ﱁ/g;
    s/ﻢﻟ/ﱂ/g;
    s/ﻰﻟ/ﱃ/g;
    s/ﻲﻟ/ﱄ/g;
    s/ﻢﻧ/ﱎ/g;
    s/ٌّ/ﱞ/g;
    s/ٍّ/ﱟ/g;
    s/َّ/ﱠ/g;
    s/ُّ/ﱡ/g;
    s/ِّ/ﱢ/g;
    s/ﺮﺒ/ﱪ/g;
    s/ﻦﺒ/ﱭ/g;
    s/ﻲﺒ/ﱯ/g;
    s/ﺮﺘ/ﱰ/g;
    s/ﻦﺘ/ﱳ/g;
    s/ﻲﺘ/ﱵ/g;
    s/ﻲﻨ/ﲏ/g;
    s/ﺮﻴ/ﲑ/g;
    s/ﻦﻴ/ﲔ/g;
    s/ﺠﺑ/ﲜ/g;
    s/ﺤﺑ/ﲝ/g;
    s/ﺨﺑ/ﲞ/g;
    s/ﻤﺑ/ﲟ/g;
    s/ﺠﺗ/ﲡ/g;
    s/ﺤﺗ/ﲢ/g;
    s/ﺨﺗ/ﲣ/g;
    s/ﻤﺗ/ﲤ/g;
    s/ﻤﺛ/ﲦ/g;
    s/ﻤﺟ/ﲨ/g;
    s/ﻤﺣ/ﲪ/g;
    s/ﻤﺧ/ﲬ/g;
    s/ﻤﺳ/ﲰ/g;
    s/ﺠﻟ/ﳉ/g;
    s/ﺤﻟ/ﳊ/g;
    s/ﺨﻟ/ﳋ/g;
    s/ﻤﻟ/ﳌ/g;
    s/ﻬﻟ/ﳍ/g;
    s/ﺠﻣ/ﳎ/g;
    s/ﺤﻣ/ﳏ/g;
    s/ﺨﻣ/ﳐ/g;
    s/ﻤﻣ/ﳑ/g;
    s/ﺠﻧ/ﳒ/g;
    s/ﺤﻧ/ﳓ/g;
    s/ﺨﻧ/ﳔ/g;
    s/ﻤﻧ/ﳕ/g;
    s/ﺠﻳ/ﳚ/g;
    s/ﺤﻳ/ﳛ/g;
    s/ﺨﻳ/ﳜ/g;
    s/ﻤﻳ/ﳝ/g;
    s/ﺤﻤﻟ/ﶈ/g;
    s/ﻪﻠﻟﺍ/ﷲ/g;
    s/ﻢﻠﺳﻭ/ﻪﻴﻠﻋ/g;
    s/ﻪﻟﺎﻠﺟ/ﻞﺟ/g;

    return decode('utf8',$_);
}

1;

# The following table lists the presentation variants of each
# character.  Each value from the U+0600 block means that the
# necessary glyph variant has not been assigned a code in Unicode's
# U+FA00 compatibility zone.  You may want to insert your private
# glyphs or approximation glyphs for them:
