#=======================================================================
#	 ____  ____  _____              _    ____ ___   ____
#	|  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
#	| |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
#	|  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
#	|_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
#	Copyright 1999-2001 Alfred Reibenschuh <areibens@cpan.org>.
#
#	This library is free software; you can redistribute it 
#	and/or modify it under the same terms as Perl itself.
#
#=======================================================================
#
#	PDF::API2::Barcode
#
#=======================================================================
package PDF::API2::Barcode;

## use strict;
use vars qw(
	@ISA

	$code3of9
	$code3of9_chk
	@bar3of9
	%bar3of9ext
	%bar_wdt

	@bar128

	$code128a
	$code128b
	$code128c

	$bar128F1
	$bar128F2
	$bar128F3
	$bar128F4
	$bar128Ca
	$bar128Cb
	$bar128Cc
	$bar128sh
	$bar128Sa
	$bar128Sb
	$bar128Sc
	$bar128St

	@ean_code_odd
	@ean_code_even
	$VERSION
);

( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

use PDF::API2::PDF::Utils;
use PDF::API2::PDF::Dict;
use PDF::API2::Util;
use PDF::API2::Hybrid;

@ISA=qw( PDF::API2::Hybrid );

%bar_wdt=(
	 0 => 0,
	 1 => 1,
	 2 => 2,
	 3 => 3,
	 4 => 4,
	 5 => 5,
	 6 => 6,
	 7 => 7,
	 8 => 8,
	 9 => 9,
	'a' => 1,
	'b' => 2,
	'c' => 3,
	'd' => 4,
	'e' => 5,
	'f' => 6,
	'g' => 7,
	'h' => 8,
	'i' => 9,
	'A' => 1,
	'B' => 2,
	'C' => 3,
	'D' => 4,
	'E' => 5,
	'F' => 6,
	'G' => 7,
	'H' => 8,
	'I' => 9,
);

$code128a=q| !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_|.join('',map{chr($_)}(0..31)).qq/\xf3\xf2\x80\xcc\xcb\xf4\xf1\x8a\x8b\x8c\xff/;
$code128b=q| !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|.qq/|}~\x7f\xf3\xf2\x80\xcc\xf4\xca\xf1\x8a\x8b\x8c\xff/;
$code128c=("\xfe" x 100).qq/\xcb\xca\xf1\x8a\x8b\x8c\xff/;

@bar128=qw(
    212222 222122 222221 121223 121322
    131222 122213 122312 132212 221213
    221312 231212 112232 122132 122231
    113222 123122 123221 223211 221132
    221231 213212 223112 312131 311222
    321122 321221 312212 322112 322211
    212123 212321 232121 111323 131123
    131321 112313 132113 132311 211313
    231113 231311 112133 112331 132131
    113123 113321 133121 313121 211331
    231131 213113 213311 213131 311123
    311321 331121 312113 312311 332111
    314111 221411 431111 111224 111422
    121124 121421 141122 141221 112214
    112412 122114 122411 142112 142211
    241211 221114 413111 241112 134111
    111242 121142 121241 114212 124112
    124211 411212 421112 421211 212141
    214121 412121 111143 111341 131141
    114113 114311 411113 411311 113141
    114131 311141 411131 b1a4a2 b1a2a4
    b1a2c2 b3c1a1b
);

$bar128F1="\xf1";
$bar128F2="\xf2";
$bar128F3="\xf3";
$bar128F4="\xf4";

$bar128Ca="\xca";
$bar128Cb="\xcb";
$bar128Cc="\xcc";

$bar128sh="\x80";

$bar128Sa="\x8a";
$bar128Sb="\x8b";
$bar128Sc="\x8c";

$bar128St="\xff";

sub encode_128_char_idx {
	my ($code,$char)=@_;
	my ($idx);
	if(lc($code) eq 'a') {
		return if($char eq $bar128Ca);
		$idx=index($code128a,$char);
	} elsif(lc($code) eq 'b') {
		return if($char eq $bar128Cb);
		$idx=index($code128b,$char);
	} elsif(lc($code) eq 'c') {
		return if($char eq $bar128Cc);
		if($char=~/^\d+$/) {
			$idx=substr($char,0,1)*10+substr($char,1,1)*1;
		} else {
			$idx=index($code128c,$char);
		}
	}
	return($bar128[$idx],$idx);
}

sub encode_128_char {
	my ($code,$char)=@_;
	my ($b)=encode_128_char_idx($code,$char);
	return($b);
}

sub encode_128_string {
	my ($code,$str)=@_;
	my ($bar,@chk,$c,$desc,$b,$i,@bars);
	my @chars=split(//,$str);
	while(defined($c=shift @chars)) {
		if($c=~/[\xf1-\xf4]/) {
			($b,$i)=encode_128_char_idx($code,$c);
		} elsif($c=~/[\xca-\xcc]/) {
			($b,$i)=encode_128_char_idx($code,$c);
			if($c eq "\xca") {
				$code='a';
			} elsif($c eq "\xcb") {
				$code='b';
			} elsif($c eq "\xcc") {
				$code='c';
			}
		} else {
			if($code ne 'c') {
				if($c eq $bar128sh) {
					($b,$i)=encode_128_char_idx($code,$c);
					push(@bars,$b);
					push(@chk,$i);
					$c=shift(@chars);
					($b,$i)=encode_128_char_idx($code eq 'a' ? 'b':'a',$c);
				} else {
					($b,$i)=encode_128_char_idx($code,$c);
				}
			} else {
				$c.=shift(@chars) if($c=~/\d/);
				if($c=~/^\d[^\d]*$/) {
					($b,$i)=encode_128_char_idx($code,"\xcb");
					push(@bars,$b);
					push(@chk,$i);
					$code='b';
					unshift(@chars,substr($c,1,1));
					$c=substr($c,0,1);
				}
				($b,$i)=encode_128_char_idx($code,$c);
			}
		}
		$c='' if($c=~/[^\x20-\x7e]/);
		push(@bars,[$b,$c]);
		push(@chk,$i);
	}
	return([@bars],@chk);
}

sub encode_128 {
	my ($code,$str)=@_;
	my (@bar,$b,@chk,$c);
	if($code eq 'a') {
		push(@bar,encode_128_char($code,$bar128Sa));
		$c=103;
	} elsif($code eq 'b') {
		push(@bar,encode_128_char($code,$bar128Sb));
		$c=104;
	} elsif($code eq 'c') {
		push(@bar,encode_128_char($code,$bar128Sc));
		$c=105;
	}
	($b,@chk)=encode_128_string($code,$str);
	# b ... bars
	# chk ... chknums
	push(@bar,@{$b});
	#calc chksum
	foreach my $i (1..scalar @chk) {
		$c+=$i*$chk[$i-1];
	}
	$c%=103;
	push(@bar,$bar128[$c]);
	push(@bar,encode_128_char($code,$bar128St));
	return(@bar);
}

sub encode_ean128 {
	my ($str)=@_;
	$str=~s/[^a-zA-Z\d]+//g;
	$str=~s/(\d+)([a-zA-Z]+)/$1\xcb$2/g;
	$str=~s/([a-zA-Z]+)(\d+)/$1\xcc$2/g;
	return(encode_128('c',"\xf1$str"));
}

$code3of9=q|1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*|;
$code3of9_chk=q|0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%|;

@bar3of9=qw/
	2112111121	1122111121	2122111111	1112211121
	2112211111	1122211111	1112112121	2112112111
	1122112111	1112212111	2111121121	1121121121
	2121121111	1111221121	2111221111	1121221111
	1111122121	2111122111	1121122111	1111222111
	2111111221	1121111221	2121111211	1111211221
	2111211211	1121211211	1111112221	2111112211
	1121112211	1111212211	2211111121	1221111121
	2221111111	1211211121	2211211111	1221211111
	1211112121	2211112111	1221112111	1212121111
	1212111211	1211121211	1112121211	abaababaa1
/;


%bar3of9ext=(
	"\x00" => '%U',
	"\x01" => '$A',
	"\x02" => '$B',
	"\x03" => '$C',
	"\x04" => '$D',
	"\x05" => '$E',
	"\x06" => '$F',
	"\x07" => '$G',
	"\x08" => '$H',
	"\x09" => '$I',
	"\x0a" => '$J',
	"\x0b" => '$K',
	"\x0c" => '$L',
	"\x0d" => '$M',
	"\x0e" => '$N',
	"\x0f" => '$O',
	"\x10" => '$P',
	"\x11" => '$Q',
	"\x12" => '$R',
	"\x13" => '$S',
	"\x14" => '$T',
	"\x15" => '$U',
	"\x16" => '$V',
	"\x17" => '$W',
	"\x18" => '$X',
	"\x19" => '$Y',
	"\x1a" => '$Z',
	"\x1b" => '%A',
	"\x1c" => '%B',
	"\x1d" => '%C',
	"\x1e" => '%D',
	"\x1f" => '$E',
	"\x20" => ' ',
	"!" => '/A',
	'"' => '/B',
	"#" => '/C',
	'$' => '/D',
	'%' => '/E',
	'&' => '/F',
	"'" => '/G',
	'(' => '/H',
	')' => '/I',
	'*' => '/J',
	'+' => '/K',
	',' => '/L',
	'-' => '-',
	'.' => '.',
	'/' => '/O',
	'0' => '0',
	'1' => '1',
	'2' => '2',
	'3' => '3',
	'4' => '4',
	'5' => '5',
	'6' => '6',
	'7' => '7',
	'8' => '8',
	'9' => '9',
	':' => '/Z',
	';' => '%F',
	'<' => '%G',
	'=' => '%H',
	'>' => '%I',
	'?' => '%J',
	'@' => '%V',
	'A' => 'A',
	'B' => 'B',
	'C' => 'C',
	'D' => 'D',
	'E' => 'E',
	'F' => 'F',
	'G' => 'G',
	'H' => 'H',
	'I' => 'I',
	'J' => 'J',
	'K' => 'K',
	'L' => 'L',
	'M' => 'M',
	'N' => 'N',
	'O' => 'O',
	'P' => 'P',
	'Q' => 'Q',
	'R' => 'R',
	'S' => 'S',
	'T' => 'T',
	'U' => 'U',
	'V' => 'V',
	'W' => 'W',
	'X' => 'X',
	'Y' => 'Y',
	'Z' => 'Z',
	'[' => '%K',
	'\\' => '%L',
	']' => '%M',
	'^' => '%N',
	'_' => '%O',
	'`' => '%W',
	'a' => '+A',
	'b' => '+B',
	'c' => '+C',
	'd' => '+D',
	'e' => '+E',
	'f' => '+F',
	'g' => '+G',
	'h' => '+H',
	'i' => '+I',
	'j' => '+J',
	'k' => '+K',
	'l' => '+L',
	'm' => '+M',
	'n' => '+N',
	'o' => '+O',
	'p' => '+P',
	'q' => '+Q',
	'r' => '+R',
	's' => '+S',
	't' => '+T',
	'u' => '+U',
	'v' => '+V',
	'w' => '+W',
	'x' => '+X',
	'y' => '+Y',
	'z' => '+Z',
	'{' => '%P',
	'|' => '%Q',
	'}' => '%R',
	'~' => '%S',
	"\x7f" => '%T'
);

sub encode_3of9_char {
	my $char=shift @_;
	return($bar3of9[index($code3of9,$char)]);
}

sub encode_3of9_string {
	my $string=shift @_;
	my $bar;
	my @c=split(//,$string);

	foreach my $char (@c) {
		$bar.=encode_3of9_char($char);
	}
	return($bar);
}

sub encode_3of9_string_w_chk {
	my $string=shift @_;
	my ($bar,$num);
	my @c=split(//,$string);

	foreach my $char (@c) {
		$num+=index($code3of9_chk,$char);
		$bar.=encode_3of9_char($char);
	}
	$num%=43;
	$bar.=$bar3of9[$num];
	return($bar);
}

sub encode_3of9 {
	my $string=shift @_;
	my @bar;

	$string=uc($string);
	$string=~s/[^0-9A-Z\-\.\ \$\/\+\%]+//g;

	push(@bar, encode_3of9_char('*') );
	push(@bar, [ encode_3of9_string($string), $string ] );
	push(@bar, $bar[0] );

	return(@bar);
}

sub encode_3of9_w_chk {
	my $string=shift @_;
	my @bar;

	$string=uc($string);
	$string=~s/[^0-9A-Z\-\.\ \$\/\+\%]+//g;

	push(@bar, encode_3of9_char('*') );
	push(@bar, [ encode_3of9_string_w_chk($string), $string ] );
	push(@bar, $bar[0] );

	return(@bar);
}

sub encode_3of9_ext {
	my $string=shift @_;
	my @c=split(//,$string);
	my ($enc,@bar);
	map { $enc.=$bar3of9ext{$_}; } (@c);

	push(@bar, encode_3of9_char('*') );
	push(@bar, [ encode_3of9_string($enc), $string ] );
	push(@bar, $bar[0] );

	return(@bar);
}

sub encode_3of9_ext_w_chk {
	my $string=shift @_;
	my @c=split(//,$string);
	my ($enc,@bar);
	map { $enc.=$bar3of9ext{$_}; } (@c);

	push(@bar, encode_3of9_char('*') );
	push(@bar, [ encode_3of9_string_w_chk($enc), $string ] );
	push(@bar, $bar[0] );

	return(@bar);
}


@ean_code_odd =qw( 3211 2221 2122 1411 1132 1231 1114 1312 1213 3112 );
@ean_code_even=qw( 1123 1222 2212 1141 2311 1321 4111 2131 3121 2113 );

sub encode_ean13 {
	my $string=shift @_;
	my @c=split(//,$string);
	my ($enc,@bar);
	my $v=shift @c;
	push(@bar,['07',"$v"]);
	push(@bar,'a1a');
	if($v==0) {
		foreach(0..5) {
			my $f=shift @c;
			push(@bar,[$ean_code_odd[$f],"$f"]);
		}
	} elsif($v==1) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
	} elsif($v==2) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
	} elsif($v==3) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
	} elsif($v==4) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
	} elsif($v==5) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
	} elsif($v==6) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
	} elsif($v==7) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
	} elsif($v==8) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
	} elsif($v==9) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_even[$f],"$f"]);
		$f=shift @c; push(@bar,[$ean_code_odd[$f],"$f"]);
	}
	push(@bar,'1a1a1');
	foreach(0..5) {
		my $f=shift @c;
		push(@bar,[$ean_code_odd[$f],"$f"]);
	}
	push(@bar,'a1a');
	return @bar;
}

=head2 PDF::API2::Barcode

Subclassed from PDF::API2::Hybrid.

=item $bc = PDF::API2::Barcode->new $pdfkey, %options

Returns a new barcode object (called from $pdf->barcode).

B<Example:>

	PDF::API2::Barcode->new(
		$key,
		-font	=> $fontobj,	# the font to use for text
		-type	=> '3of9',	# the type of barcode
		-code	=> '0123456789', # the code of the barcode
		-extn	=> '012345',	# the extension of the barcode
					# (if applicable)
		-umzn	=> 10,		# (u)pper (m)ending (z)o(n)e
		-lmzn	=> 10,		# (l)ower (m)ending (z)o(n)e
		-zone	=> 50,		# height (zone) of bars
		-quzn	=> 10,		# (qu)iet (z)o(n)e
		-ofwt	=> 0.01,	# (o)ver(f)low (w)id(t)h
		-fnsz	=> 10,		# (f)o(n)t(s)i(z)e
		-text	=> 'alternative text'
	);

B<Note:> There is currently only support for the following barcodes:

	3of9, 3of9ext, 3of9chk, 3of9extchk,
	code128a, code128b, code128c, ean128,
	ean13

=cut

sub new {
	my $class=shift @_;
	my $key=shift @_;
	my %opts=@_;
	my $self = $class->SUPER::new;
	$self->{' stream'}='';
	my (@bar,@ext);

	$opts{-type}=lc($opts{-type});
	$self->{' bfont'}=$opts{-font};

	$self->{' umzn'}=$opts{-umzn};		# (u)pper (m)ending (z)o(n)e
	$self->{' lmzn'}=$opts{-lmzn};		# (l)ower (m)ending (z)o(n)e
	$self->{' zone'}=$opts{-zone};
	$self->{' quzn'}=$opts{-quzn};		# (qu)iet (z)o(n)e
	$self->{' ofwt'}=$opts{-ofwt}||0.01;		# (o)ver(f)low (w)id(t)h
	$self->{' fnsz'}=$opts{-fnsz};		# (f)o(n)t(s)i(z)e
	$self->{' spcr'}=$opts{-spcr}||'';

        $self->{'Type'}=PDFName('XObject');
        $self->{'Subtype'}=PDFName('Form');
        $self->{'Name'}=PDFName($key);
        $self->{'Formtype'}=PDFNum(1);
        $self->{'BBox'}=PDFArray(PDFNum(0),PDFNum(0),PDFNum(1000),PDFNum(1000));

	if( $opts{-type}=~/^3of9/ ) {
		if( $opts{-type} eq '3of9' ) {
			@bar = encode_3of9($opts{-code});
		} elsif ( $opts{-type} eq '3of9ext' ) {
			@bar = encode_3of9_ext($opts{-code});
		} elsif ( $opts{-type} eq '3of9chk' ) {
			@bar = encode_3of9_w_chk($opts{-code});
		} elsif ( $opts{-type} eq '3of9extchk' ) {
			@bar = encode_3of9_ext_w_chk($opts{-code});
		}
	} elsif( $opts{-type}=~/^code128/ ) {
		if( $opts{-type} eq 'code128a' ) {
			@bar = encode_128('a',$opts{-code});
		} elsif ( $opts{-type} eq 'code128b' ) {
			@bar = encode_128('b',$opts{-code});
		} elsif ( $opts{-type} eq 'code128c' ) {
			@bar = encode_128('c',$opts{-code});
		}
	} elsif( $opts{-type}=~/^ean128/ ) {
		@bar = encode_ean128($opts{-code});
	} elsif( $opts{-type}=~/^ean13/ ) {
		@bar = encode_ean13($opts{-code});
	}

	if(scalar @ext < 1) {
		$self->drawbar([@bar],$opts{-text});
	} else {
		$self->drawbar([@bar],$opts{-text},[@ext]);
	}

	return($self);
}

sub drawbar {
	my $self=shift @_;
	my @bar=@{shift @_};
	my $bartext=shift @_;
	my $ext=shift @_;

	my $x=$self->{' quzn'};
	my ($code,$str,$f,$t,$l,$h,$xo);
	$self->fillcolorbyname('black');
	$self->strokecolorbyname('black');

	my $bw=1;
	foreach my $b (@bar) {
		if(ref($b)) {
			($code,$str)=@{$b};
		} else {
			$code=$b;
			$str=undef;
		}
		$xo=0;
		foreach my $c (split(//,$code)) {
			my $w=$bar_wdt{$c};
			$xo+=$w/2;
			if($c=~/[0-9]/) {
				$l=$self->{' quzn'} + $self->{' lmzn'};
				$h=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
				$t=$self->{' quzn'};
				$f=$self->{' fnsz'}||$self->{' lmzn'};
			} elsif($c=~/[a-z]/) {
				$l=$self->{' quzn'};
				$h=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
				$t=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
				$f=$self->{' fnsz'}||$self->{' umzn'};
			} elsif($c=~/[A-Z]/) {
				$l=$self->{' quzn'};
				$h=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'};
				$f=$self->{' fnsz'}||$self->{' umzn'};
				$t=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'} - $f;
			} else {
				$l=$self->{' quzn'} + $self->{' lmzn'};
				$h=$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
				$t=$self->{' quzn'};
				$f=$self->{' fnsz'}||$self->{' lmzn'};
			}
			if($bw) {
				if($c ne '0') {
					$self->linewidth($w-$self->{' ofwt'});
					$self->move($x+$xo,$l);
					$self->line($x+$xo,$h);
					$self->stroke;
				}
				$bw=0;
			} else {
				$bw=1;
			}
			$xo+=$w/2;
		}
		if(defined($str) && ($self->{' lmzn'}>0)) {
			$str=join($self->{' spcr'},split(//,$str));
			$self->textstart;
			$self->translate($x+($xo/2),$t);
			$self->font($self->{' bfont'},$f);
			$self->text_center($str);
			$self->textend;
		}
		$x+=$xo;
	}
	if(defined $bartext) {
		$f=$self->{' fnsz'}||$self->{' lmzn'};
		$t=$self->{' quzn'}-$f;
		$self->textstart;
		$self->translate(($self->{' quzn'}+$x)/2,$t);
		$self->font($self->{' bfont'},$f);
		$self->text_center($bartext);
		$self->textend;
	}
	$self->{' w'}=$self->{' quzn'}+$x;
	$self->{' h'}=2*$self->{' quzn'} + $self->{' lmzn'} + $self->{' zone'} + $self->{' umzn'};
}

=item $wd = $bc->width

=cut

sub width {
	my $self = shift @_;
	return($self->{' w'});
}

=item $ht = $bc->height

=cut

sub height {
	my $self = shift @_;
	return($self->{' h'});
}

sub font {
	my ($self,$font,$size)=@_;
	$self->{' font'}=$font;
	$self->{' fontsize'}=$size;
	$self->add("/".$font->{' apiname'},float($size),'Tf');

##	$self->resource('Font',$font->{' apiname'},$font);

	return($self);
}

sub outobjdeep {
	my ($self, @opts) = @_;
	foreach my $k (qw/ api apipdf apipage font fontsize charspace hspace wordspace lead rise render matrix fillcolor strokecolor translate scale skew rotate bfont /) {
		$self->{" $k"}=undef;
		delete($self->{" $k"});
	}
	PDF::API2::PDF::Dict::outobjdeep(@_);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
