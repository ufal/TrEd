package PDF::API2::PDF::AFont;


# use strict;
use vars qw(@ISA $VERSION );
@ISA = qw(PDF::API2::PDF::Dict);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:45 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

use POSIX;
use PDF::API2::PDF::Utils;
use Compress::Zlib;
use File::Find;

=head1 NAME

PDF::API2::PDF::AFont - Embedding of Adobe PFB/PFA + AFM format fonts. Inherits from
L<PDF::API2::PDF::Dict>

=head1 METHODS

=head2 PDF::API2::PDF::AFont->new $parent, $name, $psfile, $afmfile, $pdfname [ , $encoding [ , @glyphs ]]

Creates a new font object with given parent and name from pfb/pfa from psfile
and afm from afmfile.

The $pdfname is the name that this particular font object will be referenced
by throughout the PDF file. If you want to play silly games with naming, then
you can write the code to do it!

The $encoding is the name of one of the encoding schemes specified in the
pdf-specification (v1.3 2nd Ed.), 'latin1' or 'custom'. 'latin1' is a variant of 
the standard WinAnsiEncoding especially customized for iso-8859-1 (aka. iso-latin-1).
If you use 'custom' as encoding, you have to supply the @glyphs array which should
specify 256 glyph-names as defined by the "PostScript(R) Language Reference 3rd. Ed. -- Appendix E" 

If you do not give $encoding, than the afms internal encoding is used.

If you give an unknown $encoding, the encoding defaults to WinAnsiEncoding.

Returns the new font object.

=head2 PDF::API2::PDF::AFont->newNonEmbed $parent, $afmfile, $pdfname [ , $encoding [, @glyphs ]]

Creates a new font object with given parent and name from pfb/pfa from psfile
and afm from afmfile.

All the rules for PDF::API2::PDF::AFont->new apply here, but instead of having a embedded font
included in the pdf-file you only have a reference to the font included in the pdf-file.
This results in far smaller filesizes, but requires the viewing/printing application to
have the actual font properly installed at their platform.

Returns the new font object.

=head2 PDF::API2::PDF::AFont->newCore $parent, $fontname, $pdfname [, $encoding [, @glyphs ]]

Creates a new font object with given parent and fontname from one of the 14 Adobe Core Fonts
as supported by the Adobe PDF Reader applications versions 3.0 and up.

Valid values for fontname are:

	Courier-Bold
	Courier-BoldOblique
	Courier-Oblique
	Courier
	Helvetica-Bold
	Helvetica-BoldOblique
	Helvetica-Oblique
	Helvetica
	Symbol
	Times-Bold
	Times-BoldItalic
	Times-Italic
	Times-Roman
	ZapfDingbats

All the rules of PDF::API2::PDF::AFont->newNonEmbed apply here, but don't require you to specify an afm-file
since the fonts are internally supported by both the Adobe PDF Reader applications and this module.

Returns the new font object.

=cut

sub resolveFontFile {
        my $file=shift @_;
        my $fontfile=undef;
        if ( -e $file ) {
                $fontfile=$file;
        } else {
		map { my $f="$_/$file"; $fontfile=$f if(-e $f); } (map { ("$_/PDF/API2/fonts/t1", "$_/Text/PDF/fonts/t1"); }  @INC) ;
        }
	return $fontfile;
}

sub readAFM {
	my ($self,$file)=@_;
	$self->{' AFM'}={};
	if(! -e $file) {die "file='$file' not existant.";}
	open(AFMF, $file) or die "Can't find the AFM file for $file";
	local($/, $_) = ("\n", undef);  # ensure correct $INPUT_RECORD_SEPARATOR
	while ($_=<AFMF>) {
		next if /^StartKernData/ .. /^EndKernData/;  # kern data not parsed yet
		next if /^StartComposites/ .. /^EndComposites/; # same for composites
		if (/^StartCharMetrics/ .. /^EndCharMetrics/) {
		# only lines that start with "C" or "CH" are parsed
			next unless $_=~/^CH?\s/;
			my($ch)   = $_=~/^CH?\s+(\d+)\s*;/;
			$ch=$ch||0;
			my($name) = $_=~/\bN\s+(\.?\w+)\s*;/;
			my($wx)   = $_=~/\bWX\s+(\d+)\s*;/;
			my($bbox)    = $_=~/\bB\s+([^;]+);/;
			$bbox =~ s/\s+$//;
			# Should also parse lingature data (format: L successor lignature)
			$self->{' AFM'}->{'wx'}{$name} = $wx ;
			$self->{' AFM'}->{'bbox'}{$name} = $bbox ;
			if($ch>0) {
				$self->{' AFM'}->{'char'}[$ch]=$name ;
			} 
			next;
		}
		last if $_=~/^EndFontMetrics/;
		if (/(^\w+)\s+(.*)/) {
			my($key,$val) = ($1, $2);
			$key = lc $key;
			if (defined $self->{' AFM'}->{$key}) {
			#	$self->{' AFM'}->{$key} = [ $self->{' AFM'}->{$key} ] unless ref $self->{' AFM'}->{$key};
			#	push(@{$self->{' AFM'}->{$key}}, $val);
			} else {
				$val=~s/[\x00\x1f]+//g;
				$self->{' AFM'}->{$key} = $val;
			}
		} else {
           		print STDERR "Can't parse: $_";
		}
	}
	close(AFMF);
	unless (exists $self->{' AFM'}->{wx}->{'.notdef'}) {
		$self->{' AFM'}->{wx}->{'.notdef'} = 0;
		$self->{' AFM'}->{bbox}{'.notdef'} = "0 0 0 0";
	}
	$self->{' AFM'}->{'fontname'}=~s/[\x00-\x1f]+//g;

}

sub readPSF {
	my ($self,$ascii,$bin)=@_;
	my (@asci,%h,$x);
	
	@asci=split(/[\x0d\x0a]+/,$ascii);
	foreach my $line (@asci){
		$h{lc($1)}=$2 if($line=~/^\/(\w+)([^\w].*)def$/) ;
	}	

	foreach my $x (keys %h) {
		$h{$x}=~s/^\s*[\(\[\{](.+)[\}\]\)]\s*readonly\s*$/$1/i if($h{$x}=~/readonly/);	
		$h{$x}=~s/^\s+//gi;
		$h{$x}=~s/\s+$//gi;
	}
	$h{'fontname'}=~s|/||gi;

	($x,$x,$x,$wy)=split(/\s+/,$h{'fontbbx'});


    my $newdata = "";

    # Conversion based on an C-program marked as follows:
    # /* Written by Carsten Wiethoff 1989 */
    # /* You may do what you want with this code,
    #    as long as this notice stays in it */

    my $input;
    my $output;
    my $ignore = 4;
    my $buffer = 0xd971;

    while ( length($bin) > 0 ) {
	($input, $bin) = $bin =~ /^(.)(.*)$/s;
	$input = ord ($input);
	$output = $input ^ ($buffer >> 8);
	$buffer = (($input + $buffer) * 0xce6d + 0x58bf) & 0xffff;
	next if $ignore-- > 0;
	$newdata .= pack ("C", $output);
    }

#	print $newdata;
    # End conversion.

	@asci=split(/[\x0d\x0a]/,$newdata);
        map {
                my($s,$t)=$_=~/^\/(\w+)\s(.+)\sdef$/;
                $t=~s|[\/\(\)\[\]\{\}]||gi;
                $t=~s|^\s+||gi;
                $t=~s|\s+$||gi;
                $t=~s|\s+noaccess$||gi;
                $h{lc($s)}=$t;
        } grep(/^\/(\w+)\s(.+)\sdef$/,@asci);
	@asci=grep(/^\/\w+\s\d+\sRD\s/,@asci);
	
	$h{'wx'}=();	
	$h{'bbx'}=();	
	foreach my $line (@asci) {
		my($ch,$num,$bin)=($line=~/^\/(\w+)\s+(\d+)\s+RD\s+(.+)$/);
	#	if($num>length($bin)){
	#		($ch,$num,$bin)=($newdata=~/\/($ch)\s+($num)\s+RD\s+(.+)ND/gm);
	#	}
		my @values;
		$input='';
		$output='';
		$ignore=4;
		$buffer=0x10ea; # =4330;
		# print "values1='".join('.',map { sprintf('%02X',unpack('C',$_)) } split(//,$bin))."'\n";
		# print "values1='".pack('H*',unpack('C*',split(//,$bin)))."'\n";
		while ( length($bin) > 0 ) {
			($input, $bin) = $bin =~ /^(.)(.*)$/s;
			$input = ord ($input);
			$output = $input ^ ($buffer >> 8);
			$buffer = (($input + $buffer) * 0xce6d + 0x58bf) & 0xffff;
			next if $ignore-- > 0;
			push(@values,$output);
		}
		# print "values2='".join(':',@values)."'\n";
		my @v2;
		while($input=shift @values) {
			if($input<32){
				push(@v2,$input);
				last;
			} elsif($input<247) {
				push(@v2,$input-139);
			} elsif($input<251) {
				my $w=shift @values;
				push(@v2,(($input-247)*256)+$w+108);
			} elsif($input<255) {
				my $w=shift @values;
				push(@v2,(-($input-251)*256)-$w-108);
			} else { # == 255
				#
				$output=pack('C',shift @values);
				$output.=pack('C',shift @values);
				$output.=pack('C',shift @values);
				$output.=pack('C',shift @values);
				$output=unpack('N',$output);
				push(@v2,$output);
			}
		}
		$input=pop(@v2);
		if($input==12){
			# print "unknown bbx command at glyph='$ch' stack='".join(',',@v2)."' command='$input'\n";
			$h{'wx'}{$ch}=$v2[2];
			$h{'bbx'}{$ch}=sprintf("%d %d %d %d",$v2[0],$v2[1],$v2[2]-$v2[0],$v2[3]-$v2[1]);
			# print "G='$ch' WX='$v2[2]' BBX='".$h{'bbx'}{$ch}."'\n";
		} elsif($input==13) {
			# print "unknown bbx command at glyph='$ch' stack='".join(',',@v2)."' command='$input'\n";
			$h{'wx'}{$ch}=$v2[1];
			$h{'bbx'}{$ch}=sprintf("%d %d %d %d",$v2[0],0,$v2[1]-$v2[0],$wy);
			# print "G='$ch' WX='$v2[1]' BBX='".$h{'bbx'}{$ch}."'\n";
		} else {
			# print "unknown bbx command at glyph='$ch' stack='".join(',',@v2)."' command='$input'\n";
			$h{'wx'}{$ch}=0;
			$h{'bbx'}{$ch}="0 0 0 0";
		}
	}
	my($llx,$lly,$urx,$ury,$l,$delta);
	# now we get the rest of the required parameters
	my @blue_val=split(/\s+/,$h{'bluevalues'});
	my @bbx=split(/\s+/,$h{'fontbbx'});
	#
	#capheight 
	# get ury from H or bbx and adjust per delta blue
	($llx,$lly,$urx,$ury)=split(/\s+/,$h{'bbx'}{'H'});
	$l=$ury||$bbx[3];
	$delta=10000;
	foreach my $b (@blue_val) {
		if($delta>abs($b-$l)){
			$delta=abs($b-$l);
		} else {
			$h{'capheight'}=$b;
			last;
		}
	}

	#xheight 
	# get ury from x or bbx/2 and adjust per delta blue
	($llx,$lly,$urx,$ury)=split(/\s+/,$h{'bbx'}{'x'});
	$l=$ury||POSIX::ceil($bbx[3]/2);
	$delta=10000;
	foreach my $b (@blue_val) {
		if($delta>abs($b-$l)){
			$delta=abs($b-$l);
		} else {
			$h{'xheight'}=$b;
			last;
		}
	}

	$h{'ascender'}=0;
	$h{'descender'}=0;

	$self->{' AFM'}={%h};
	$self->{' AFM'}->{fontname}=~s/[\x00-\x1f]+//g;
	return(%h);
}

sub parsePS {
	my ($self,$file,$noFM)=@_;
	my ($l,$l1,$l2,$l3,$stream,@lines,$line,$head,$body,$tail);
	if(! -e $file) {die "file='$file' not existant.";}
	$l=-s $file;
	open(INF,$file);
	binmode(INF);
	read(INF,$line,2);
	@lines=unpack('C*',$line);
	if(($lines[0]==0x80) && ($lines[1]==1)) {
		read(INF,$line,4);
		$l1=unpack('V',$line);
		seek(INF,$l1,1);
		read(INF,$line,2);
		@lines=unpack('C*',$line);
		if(($lines[0]==0x80) && ($lines[1]==2)) {
			read(INF,$line,4);
			$l2=unpack('V',$line);
		} else {
			die "corrupt pfb in file '$file' at marker='2'.";
		}
		seek(INF,$l2,1);
		read(INF,$line,2);
		@lines=unpack('C*',$line);
		if(($lines[0]==0x80) && ($lines[1]==1)) {
			read(INF,$line,4);
			$l3=unpack('V',$line);
		} else {
			die "corrupt pfb in file '$file' at marker='3'.";
		}
		seek(INF,0,0);
		@lines=<INF>;
		close(INF);
		$stream=join('',@lines);
	} elsif($line eq '%!') {
		seek(INF,0,0);
		while($line=<INF>) {
			if(!$l1) {
				$head.=$line;
				if($line=~/eexec$/){
					chomp($head);
					$head.="\x0d";
					$l1=length($head);
				}
			} elsif(!$l2) {
				if($line=~/^0+$/) {
					$l2=length($body);
					$tail=$line;
				} else {
					chomp($line);
					$body.=pack('H*',$line);
				}
			} else {
				$tail.=$line;
			}
		}
		$l3=length($tail);
		$stream=pack('C2V',0x80,1,$l1).$head;
		$stream.=pack('C2V',0x80,2,$l2).$body;
		$stream.=pack('C2V',0x80,1,$l3).$tail;
	} else {
		die "unsupported font-format in file '$file' at marker='1'.";
	}
	my %h;
	if($noFM) {
		# now we process the portions to return a hash which makes data available
		# if we dont have a good enough afm or pfm file to parse (especially pfm :)
		%h=$self->readPSF(
			substr($stream,6,$l1) ,  	# this is the ascii portion of the font
			substr($stream,12+$l1,$l2)	# this is the binary portion of the font
		);
	}
	my $t1stream=substr($stream,6,$l1);
	$t1stream.=substr($stream,12+$l1,$l2);
	$t1stream.=substr($stream,18+$l1+$l2,$l3);
	return($l1,$l2,$l3,$t1stream,%h);
}

sub encodeProper {
	my ($self, $encoding, $first,$last, @glyphs) = @_;
	my (@w);

	if($encoding) {
		$self->{'Encoding'}=PDFDict();
		$self->{'Encoding'}->{'Type'}=PDFName('Encoding');
		if( $encoding eq 'MacRomanEncoding' ) {
			@{$self->{' AFM'}->{'char'}}=@mac_enc;
		} elsif( $encoding eq 'WinAnsiEncoding' ) {
			@{$self->{' AFM'}->{'char'}}=@win_enc;
		} elsif( $encoding=~/StandardEncoding$/ ) {
			$encoding='WinAnsiEncoding';
			@{$self->{' AFM'}->{'char'}}=@std_enc;
		} elsif( lc($encoding) eq 'latin1' ) {
			$encoding='WinAnsiEncoding';
			@{$self->{' AFM'}->{'char'}}=@latin1_enc;
			@glyphs = @latin1_enc;
		} elsif( lc($encoding) eq 'custom' ) {
			$encoding='WinAnsiEncoding';
			@{$self->{' AFM'}->{'char'}}=@glyphs;
		} elsif( lc($encoding) eq 'asis' ) {
			undef($encoding);
		} else {
			$encoding='WinAnsiEncoding';
			@{$self->{' AFM'}->{'char'}}=@win_enc;
		}
		$self->{'Encoding'}->{'BaseEncoding'}=PDFName($encoding) if($encoding);
		my $notdefbefore=1;
		@w=();
		if(@glyphs){
			foreach my $w ($first..$last) {
				if($glyphs[$w] eq '.notdef') {
					$notdefbefore=1;
					next;
				} else {
					if($notdefbefore) {
						push(@w,PDFNum($w))
					}
					$notdefbefore=0;
					push(@w,PDFName($glyphs[$w]));
				}
			}
			$self->{'Encoding'}->{'Differences'}=PDFArray(@w);
		}
	}
	@w = map { 
		PDFNum($self->{' AFM'}->{'wx'}{$_ || '.notdef'} || 300) 
	} map {
		$self->{' AFM'}->{'char'}[$_]	
	} ($first..$last);
	$self->{'Widths'}=PDFArray(@w);
	return($self);
}

sub newNonEmbed {
	my ($class, $parent, $file2, $pdfname, $encoding, @glyphs) = @_;
	my ($self);
	my (@w);
	
	$self = $file2 ? $class->SUPER::new : $class;
	$self->readAFM($file2) if($file2);
	$self->{' AFM'}->{'fontname'}=~s/[\x00-\x1f]+//gm;
	$self->{'Type'} = PDFName("Font");
	$self->{'Subtype'} = PDFName("Type1");
	$self->{'BaseFont'} = PDFName($self->{' AFM'}->{'fontname'});
	$self->{'FirstChar'} = PDFNum(32);
	$self->{'LastChar'} = PDFNum(255);
	$self->{'Name'} = PDFName($pdfname);

	$self->encodeProper( $file2 ? $encoding : 'WinAnsiEncoding' , 32, 255, @glyphs);
	
	$self->{'FontDescriptor'}=PDFDict();
	$self->{'FontDescriptor'}->{'Type'}=PDFName('FontDescriptor');
	$self->{'FontDescriptor'}->{'FontName'}=PDFName($self->{' AFM'}->{'fontname'});
	$self->{'FontDescriptor'}->{'Ascent'}=PDFNum($self->{' AFM'}->{'ascender'}||0);
	$self->{'FontDescriptor'}->{'Descent'}=PDFNum($self->{' AFM'}->{'descender'}||0);
	$self->{'FontDescriptor'}->{'ItalicAngle'}=PDFNum($self->{' AFM'}->{'italicangle'}||0);
	@w = map { PDFNum($_ || 0) } split(/\s+/,$self->{' AFM'}->{'fontbbox'});
	$self->{'FontDescriptor'}->{'CapHeight'}=PDFNum($self->{' AFM'}->{'capheight'}||$w[3]->val||0);
	$self->{'FontDescriptor'}->{'FontBBox'}=PDFArray(@w);
	$self->{'FontDescriptor'}->{'StemV'}=PDFNum(0);
	$self->{'FontDescriptor'}->{'StemH'}=PDFNum(0);
	$self->{'FontDescriptor'}->{'XHeight'}=PDFNum($self->{' AFM'}->{'xheight'}||$w[3]->val||0);

	$self->{' ascent'}=$self->{' AFM'}->{'ascender'}||0;
	$self->{' descent'}=$self->{' AFM'}->{'descender'}||0;
	$self->{' italicangle'}=$self->{' AFM'}->{'italicangle'}||0;
	$self->{' fontbbox'}=[ split(/\s+/,$self->{' AFM'}->{'fontbbox'}) ];
	$self->{' capheight'}=$self->{' AFM'}->{'capheight'}||$w[3]->val||0;
	$self->{' xheight'}=$self->{' AFM'}->{'xheight'}||$w[3]->val||0;
	
	my $flags=0;
	$self->{' AFM'}->{'encoding'}=$self->{' AFM'}->{'encoding'}||'';
	$flags|=1 if(lc($self->{' AFM'}->{'isfixedpitch'}) ne 'false');
	if($self->{' AFM'}->{'encoding'}=~/standardencoding/gi){
		$flags|=1<<5 ;
	} else {
		$flags|=1<<2 ;
		$flags|=1<<3 ;
	}
	$flags|=1<<6 if(!$self->{' AFM'}->{'italicangle'});
	$flags|=1<<17 if($self->{' AFM'}->{'fontname'}=~/SC$/);
	$flags|=1<<16 if($self->{' AFM'}->{'fontname'}=~/Caps/);
	$flags|=1<<18 if($self->{' AFM'}->{'fontname'}=~/(Heavy|Bold)/);

	$self->{'FontDescriptor'}->{'Flags'}=PDFNum($flags);
	
	if(defined($parent) && !$self->is_obj($parent)) {
		$parent->new_obj($self);
	}
	return($self);
}

sub newCore {
	my ($class, $parent, $name, $pdfname, $encoding, @glyphs) = @_;
	my ($file,$file2,$file3);
	
	$file=resolveFontFile("$name.afm");
	$file2=resolveFontFile("$name.pfa");
	$file3=resolveFontFile("$name.pfb");
	
	if(! -e $file) {die "file='$file' (was '$name.afm') not existant.";}

	if(defined $file2 && -e $file2) {
		return(new($class, $parent, $file2, $file, $pdfname, $encoding, @glyphs));
	}
	if(defined $file3 && -e $file3) {
		return(new($class, $parent, $file3, $file, $pdfname, $encoding, @glyphs));
	}

	$self=newNonEmbed($class, $parent, $file, $pdfname, $encoding, @glyphs);

	return($self);
}

sub newNonEmbedLight {
	my ($class, $parent, $file2, $pdfname,$name) = @_;
	my ($self);
	my (@w);
	
	$self = $class->SUPER::new;
	$self->readAFM($file2) if($file2);
	$self->{' AFM'}->{'fontname'}=~s/[\x00-\x1f]+//gm;
	$self->{'Type'} = PDFName("Font");
	$self->{'Subtype'} = PDFName("Type1");
	$self->{'BaseFont'} = PDFName($self->{' AFM'}->{'fontname'} || $name);
	$self->{'Name'} = PDFName($pdfname);
	@w=split(/\s+/,$self->{' AFM'}->{'fontbbox'});
	$self->{' ascent'}=$self->{' AFM'}->{'ascender'}||0;
	$self->{' descent'}=$self->{' AFM'}->{'descender'}||0;
	$self->{' italicangle'}=$self->{' AFM'}->{'italicangle'}||0;
	$self->{' fontbbox'}=[ @w ];
	$self->{' capheight'}=$self->{' AFM'}->{'capheight'}||$w[3]||0;
	$self->{' xheight'}=$self->{' AFM'}->{'xheight'}||($w[3]/2)||0;
	
	if(defined($parent) && !$self->is_obj($parent)) {
		$parent->new_obj($self);
	}
	return($self);
}

sub encodeProperLight {
	my ($self, $encoding,$first,$last, @glyphs) = @_;
	my (@w);

	if($encoding) {
		if( $encoding eq 'MacRomanEncoding' ) {
			@{$self->{' AFM'}->{'char'}}=@mac_enc;
		} elsif( $encoding eq 'WinAnsiEncoding' ) {
			@{$self->{' AFM'}->{'char'}}=@win_enc;
		} elsif( $encoding=~/StandardEncoding$/ ) {
			$encoding='WinAnsiEncoding';
			@{$self->{' AFM'}->{'char'}}=@std_enc;
		} elsif( lc($encoding) eq 'latin1' ) {
			$encoding='WinAnsiEncoding';
			@{$self->{' AFM'}->{'char'}}=@latin1_enc;
			@glyphs = @latin1_enc;
		} elsif( lc($encoding) eq 'custom' ) {
			$encoding='WinAnsiEncoding';
			@{$self->{' AFM'}->{'char'}}=@glyphs;
		} elsif( lc($encoding) eq 'asis' ) {
			undef($encoding);
		} else {
			$encoding='WinAnsiEncoding';
			@{$self->{' AFM'}->{'char'}}=@win_enc;
		}
		$self->{'Encoding'}=PDFDict();
		$self->{'Encoding'}->{'Type'}=PDFName('Encoding');
		$self->{'Encoding'}->{'BaseEncoding'}=PDFName($encoding) if($encoding);
		my $notdefbefore=1;
		@w=();
		if(@glyphs){
			foreach my $w ($first..$last) {
				if($glyphs[$w] eq '.notdef') {
					$notdefbefore=1;
					next;
				} else {
					if($notdefbefore) {
						push(@w,PDFNum($w))
					}
					$notdefbefore=0;
					push(@w,PDFName($glyphs[$w]));
				}
			}
			$self->{'Encoding'}->{'Differences'}=PDFArray(@w);
		}
	}
}


sub newCoreLight {
	my ($class, $parent, $name, $pdfname) = @_;
	my ($file);
	
	$file=resolveFontFile("$name.afm");
	if(! -e $file) {
	#	print STDERR "could not find '$name.afm' resolving gracefully.\n"; 
		$file=undef;
	}

	$self=newNonEmbedLight($class, $parent, $file, $pdfname, $name);
	$self->{' light'}=1;
	return($self);
}


sub new {
	my ($class, $parent, $file1, $file2, $pdfname, $encoding, @glyphs) = @_;
	my (@w);
	my ($l1,$l2,$l3,$stream);
	if($file1) {
		if($file2) {
			$self=newNonEmbed($class, $parent, $file2, $pdfname, $encoding, @glyphs);
			($l1,$l2,$l3,$stream)=$self->parsePS($file1,0);
		} else {
			$self=$class->SUPER::new();
			($l1,$l2,$l3,$stream)=$self->parsePS($file1,1);
			$self->newNonEmbed($parent, $file2, $pdfname, $encoding, @glyphs);
		}
		my $s = PDFDict();
		$self->{'FontDescriptor'}->{'FontFile'} = $s;
		$s->{'Length1'} = PDFNum($l1);
		$s->{'Length2'} = PDFNum($l2);
		$s->{'Length3'} = PDFNum($l3);
		$s->{'Filter'} = PDFArray(PDFName("FlateDecode"));
		$s->{' stream'} = $stream;
		if(defined $parent) {
			$parent->new_obj($s);
		}
	} else {
		$self=newNonEmbed($class, $parent, $file2, $pdfname, $encoding, @glyphs);
	}
	
	if(defined($parent) && !$self->is_obj($parent)) {
	##	$parent->new_obj($self->{'FontDescriptor'});
		$parent->new_obj($self);
	}
	return($self);
}

=head2 $f->reencode $parentpdf $pdfname $encoding [@glyphs]

Reencodes the current font $f with encoding $encoding (optional variant @glyphs)
to be used with name $pdfname.

Returns the new font object.

=cut

sub reencode {
	my ($class, $parent, $pdfname, $encoding, @glyphs) = @_;
	my ($self) = $class->SUPER::new;
	my (@w);
	$self->{' AFM'}={};
	%{$self->{' AFM'}->{'wx'}} = map { $_ => $class->{' AFM'}->{'wx'}{$_} } keys %{$class->{' AFM'}->{'wx'}};
	%{$self->{' AFM'}->{'bbox'}} = map { $_ => $class->{' AFM'}->{'bbox'}{$_} } keys %{$class->{' AFM'}->{'bbox'}};
	@{$self->{' AFM'}->{'char'}}=@{$class->{' AFM'}->{'char'}};
	$self->{'Type'} = PDFName("Font");
	$self->{'Subtype'} = PDFName("Type1");
	$self->{'BaseFont'} = PDFName($class->{' AFM'}->{'fontname'});
	$self->{'FirstChar'} = PDFNum(32);
	$self->{'LastChar'} = PDFNum(255);
	$self->{'Name'} = PDFName($pdfname);
	
	$self->encodeProper($encoding,32,255, @glyphs);
		
	$self->{'FontDescriptor'}=$class->{'FontDescriptor'};
	if(defined $parent) {
		$parent->new_obj($self);
	}
	return($self);
}


=head2 $f->width($text)

Returns the width of the text in em.

=cut

sub width
{
    my ($self, $text) = @_;
    my $width=0;
    foreach (unpack("C*", $text)) { 
    	$width += $self->{' AFM'}{'wx'}{$self->{' AFM'}{'char'}[$_]||'space'}||0; 
    }
    return($width / 1000);
}

=item ($llx,$lly,$urx,$ury) = $font->bbox $text

Returns the texts bounding-box as if it were at size 1.

=cut

sub bbox {
	my ($self,$text)=@_;
	my $width=$self->width(substr($text,0,length($text)-1));
	my @f=@{$self->{' AFM'}{'bbx'}{$self->{' AFM'}{'char'}[unpack("C",substr($text,0,1))]}};
	my @l=@{$self->{' AFM'}{'bbx'}{$self->{' AFM'}{'char'}[unpack("C",substr($text,-1,1))]}};
	my ($high,$low);
	foreach (unpack("C*", $text)) {
		$high = $self->{' AFM'}{'bbx'}{$self->{' AFM'}{'char'}[$_]}->[3]>$high ? $self->{' AFM'}{'bbx'}{$self->{' AFM'}{'char'}[$_]}->[3] : $high;
		$low  = $self->{' AFM'}{'bbx'}{$self->{' AFM'}{'char'}[$_]}->[1]<$low  ? $self->{' AFM'}{'bbx'}{$self->{' AFM'}{'char'}[$_]}->[1] : $low;
	}
	return map {$_/1000} ($f[0],$low,(($width*1000)+$l[2]),$high);
}

=head2 $f->out_text($text)

Acknowledges the text to be output for subsetting purposes, etc.

=cut

sub out_text
{
    my ($self, $text) = @_;

    return PDFStr($text)->as_pdf;
}

BEGIN
{
@win_enc = (
        '.notdef',      # hex=0x00 oct=0000 dec=0
        '.notdef',      # hex=0x01 oct=0001 dec=1
        '.notdef',      # hex=0x02 oct=0002 dec=2
        '.notdef',      # hex=0x03 oct=0003 dec=3
        '.notdef',      # hex=0x04 oct=0004 dec=4
        '.notdef',      # hex=0x05 oct=0005 dec=5
        '.notdef',      # hex=0x06 oct=0006 dec=6
        '.notdef',      # hex=0x07 oct=0007 dec=7
        '.notdef',      # hex=0x08 oct=0010 dec=8
        '.notdef',      # hex=0x09 oct=0011 dec=9
        '.notdef',      # hex=0x0a oct=0012 dec=10
        '.notdef',      # hex=0x0b oct=0013 dec=11
        '.notdef',      # hex=0x0c oct=0014 dec=12
        '.notdef',      # hex=0x0d oct=0015 dec=13
        '.notdef',      # hex=0x0e oct=0016 dec=14
        '.notdef',      # hex=0x0f oct=0017 dec=15
        '.notdef',      # hex=0x10 oct=0020 dec=16
        '.notdef',      # hex=0x11 oct=0021 dec=17
        '.notdef',      # hex=0x12 oct=0022 dec=18
        '.notdef',      # hex=0x13 oct=0023 dec=19
        '.notdef',      # hex=0x14 oct=0024 dec=20
        '.notdef',      # hex=0x15 oct=0025 dec=21
        '.notdef',      # hex=0x16 oct=0026 dec=22
        '.notdef',      # hex=0x17 oct=0027 dec=23
        '.notdef',      # hex=0x18 oct=0030 dec=24
        '.notdef',      # hex=0x19 oct=0031 dec=25
        '.notdef',      # hex=0x1a oct=0032 dec=26
        '.notdef',      # hex=0x1b oct=0033 dec=27
        '.notdef',      # hex=0x1c oct=0034 dec=28
        '.notdef',      # hex=0x1d oct=0035 dec=29
        '.notdef',      # hex=0x1e oct=0036 dec=30
        '.notdef',      # hex=0x1f oct=0037 dec=31
        'space',        # hex=0x20 oct=0040 dec=32
        'exclam',       # hex=0x21 oct=0041 dec=33
        'quotedbl',     # hex=0x22 oct=0042 dec=34
        'numbersign',   # hex=0x23 oct=0043 dec=35
        'dollar',       # hex=0x24 oct=0044 dec=36
        'percent',      # hex=0x25 oct=0045 dec=37
        'ampersand',    # hex=0x26 oct=0046 dec=38
        'quotesingle',  # hex=0x27 oct=0047 dec=39
        'parenleft',    # hex=0x28 oct=0050 dec=40
        'parenright',   # hex=0x29 oct=0051 dec=41
        'asterisk',     # hex=0x2a oct=0052 dec=42
        'plus', # hex=0x2b oct=0053 dec=43
        'comma',        # hex=0x2c oct=0054 dec=44
        'hyphen',       # hex=0x2d oct=0055 dec=45
        'period',       # hex=0x2e oct=0056 dec=46
        'slash',        # hex=0x2f oct=0057 dec=47
        'zero', # hex=0x30 oct=0060 dec=48
        'one',  # hex=0x31 oct=0061 dec=49
        'two',  # hex=0x32 oct=0062 dec=50
        'three',        # hex=0x33 oct=0063 dec=51
        'four', # hex=0x34 oct=0064 dec=52
        'five', # hex=0x35 oct=0065 dec=53
        'six',  # hex=0x36 oct=0066 dec=54
        'seven',        # hex=0x37 oct=0067 dec=55
        'eight',        # hex=0x38 oct=0070 dec=56
        'nine', # hex=0x39 oct=0071 dec=57
        'colon',        # hex=0x3a oct=0072 dec=58
        'semicolon',    # hex=0x3b oct=0073 dec=59
        'less', # hex=0x3c oct=0074 dec=60
        'equal',        # hex=0x3d oct=0075 dec=61
        'greater',      # hex=0x3e oct=0076 dec=62
        'question',     # hex=0x3f oct=0077 dec=63
        'at',   # hex=0x40 oct=0100 dec=64
        'A',    # hex=0x41 oct=0101 dec=65
        'B',    # hex=0x42 oct=0102 dec=66
        'C',    # hex=0x43 oct=0103 dec=67
        'D',    # hex=0x44 oct=0104 dec=68
        'E',    # hex=0x45 oct=0105 dec=69
        'F',    # hex=0x46 oct=0106 dec=70
        'G',    # hex=0x47 oct=0107 dec=71
        'H',    # hex=0x48 oct=0110 dec=72
        'I',    # hex=0x49 oct=0111 dec=73
        'J',    # hex=0x4a oct=0112 dec=74
        'K',    # hex=0x4b oct=0113 dec=75
        'L',    # hex=0x4c oct=0114 dec=76
        'M',    # hex=0x4d oct=0115 dec=77
        'N',    # hex=0x4e oct=0116 dec=78
        'O',    # hex=0x4f oct=0117 dec=79
        'P',    # hex=0x50 oct=0120 dec=80
        'Q',    # hex=0x51 oct=0121 dec=81
        'R',    # hex=0x52 oct=0122 dec=82
        'S',    # hex=0x53 oct=0123 dec=83
        'T',    # hex=0x54 oct=0124 dec=84
        'U',    # hex=0x55 oct=0125 dec=85
        'V',    # hex=0x56 oct=0126 dec=86
        'W',    # hex=0x57 oct=0127 dec=87
        'X',    # hex=0x58 oct=0130 dec=88
        'Y',    # hex=0x59 oct=0131 dec=89
        'Z',    # hex=0x5a oct=0132 dec=90
        'bracketleft',  # hex=0x5b oct=0133 dec=91
        'backslash',    # hex=0x5c oct=0134 dec=92
        'bracketright', # hex=0x5d oct=0135 dec=93
        'asciicircum',  # hex=0x5e oct=0136 dec=94
        'underscore',   # hex=0x5f oct=0137 dec=95
        'grave',        # hex=0x60 oct=0140 dec=96
        'a',    # hex=0x61 oct=0141 dec=97
        'b',    # hex=0x62 oct=0142 dec=98
        'c',    # hex=0x63 oct=0143 dec=99
        'd',    # hex=0x64 oct=0144 dec=100
        'e',    # hex=0x65 oct=0145 dec=101
        'f',    # hex=0x66 oct=0146 dec=102
        'g',    # hex=0x67 oct=0147 dec=103
        'h',    # hex=0x68 oct=0150 dec=104
        'i',    # hex=0x69 oct=0151 dec=105
        'j',    # hex=0x6a oct=0152 dec=106
        'k',    # hex=0x6b oct=0153 dec=107
        'l',    # hex=0x6c oct=0154 dec=108
        'm',    # hex=0x6d oct=0155 dec=109
        'n',    # hex=0x6e oct=0156 dec=110
        'o',    # hex=0x6f oct=0157 dec=111
        'p',    # hex=0x70 oct=0160 dec=112
        'q',    # hex=0x71 oct=0161 dec=113
        'r',    # hex=0x72 oct=0162 dec=114
        's',    # hex=0x73 oct=0163 dec=115
        't',    # hex=0x74 oct=0164 dec=116
        'u',    # hex=0x75 oct=0165 dec=117
        'v',    # hex=0x76 oct=0166 dec=118
        'w',    # hex=0x77 oct=0167 dec=119
        'x',    # hex=0x78 oct=0170 dec=120
        'y',    # hex=0x79 oct=0171 dec=121
        'z',    # hex=0x7a oct=0172 dec=122
        'braceleft',    # hex=0x7b oct=0173 dec=123
        'bar',  # hex=0x7c oct=0174 dec=124
        'braceright',   # hex=0x7d oct=0175 dec=125
        'asciitilde',   # hex=0x7e oct=0176 dec=126
        'bullet',      # hex=0x7f oct=0177 dec=127
        'Euro',      # hex=0x80 oct=0200 dec=128
        'bullet',      # hex=0x81 oct=0201 dec=129
        'quotesinglbase',       # hex=0x82 oct=0202 dec=130
        'florin',       # hex=0x83 oct=0203 dec=131
        'quotedblbase', # hex=0x84 oct=0204 dec=132
        'ellipsis',     # hex=0x85 oct=0205 dec=133
        'dagger',       # hex=0x86 oct=0206 dec=134
        'daggerdbl',    # hex=0x87 oct=0207 dec=135
        'circumflex',   # hex=0x88 oct=0210 dec=136
        'perthousand',  # hex=0x89 oct=0211 dec=137
        'Scaron',       # hex=0x8a oct=0212 dec=138
        'guilsinglleft',        # hex=0x8b oct=0213 dec=139
        'OE',   # hex=0x8c oct=0214 dec=140
        'bullet',      # hex=0x8d oct=0215 dec=141
        'Zcaron',      # hex=0x8e oct=0216 dec=142
        'bullet',      # hex=0x8f oct=0217 dec=143
        'bullet',      # hex=0x90 oct=0220 dec=144
        'quoteleft',    # hex=0x91 oct=0221 dec=145
        'quoteright',   # hex=0x92 oct=0222 dec=146
        'quotedblleft', # hex=0x93 oct=0223 dec=147
        'quotedblright',        # hex=0x94 oct=0224 dec=148
        'bullet',      # hex=0x95 oct=0225 dec=149
        'endash',       # hex=0x96 oct=0226 dec=150
        'emdash',       # hex=0x97 oct=0227 dec=151
        'tilde',        # hex=0x98 oct=0230 dec=152
        'trademark',    # hex=0x99 oct=0231 dec=153
        'scaron',       # hex=0x9a oct=0232 dec=154
        'guilsinglright',       # hex=0x9b oct=0233 dec=155
        'oe',   # hex=0x9c oct=0234 dec=156
        'bullet',      # hex=0x9d oct=0235 dec=157
        'zcaron',       # hex=0x9e oct=0236 dec=158
        'Ydieresis',    # hex=0x9f oct=0237 dec=159
        'space',      # hex=0xa0 oct=0240 dec=160
        'exclamdown',   # hex=0xa1 oct=0241 dec=161
        'cent', # hex=0xa2 oct=0242 dec=162
        'sterling',     # hex=0xa3 oct=0243 dec=163
        'currency',      # hex=0xa4 oct=0244 dec=164
        'yen',  # hex=0xa5 oct=0245 dec=165
        'brokenbar',    # hex=0xa6 oct=0246 dec=166
        'section',      # hex=0xa7 oct=0247 dec=167
        'dieresis',     # hex=0xa8 oct=0250 dec=168
        'copyright',    # hex=0xa9 oct=0251 dec=169
        'ordfeminine',  # hex=0xaa oct=0252 dec=170
        'guillemotleft',      # hex=0xab oct=0253 dec=171
        'logicalnot',   # hex=0xac oct=0254 dec=172
        'hyphen',      # hex=0xad oct=0255 dec=173
        'registered',   # hex=0xae oct=0256 dec=174
        'macron',       # hex=0xaf oct=0257 dec=175
        'degree',       # hex=0xb0 oct=0260 dec=176
        'plusminus',    # hex=0xb1 oct=0261 dec=177
        'twosuperior',  # hex=0xb2 oct=0262 dec=178
        'threesuperior',        # hex=0xb3 oct=0263 dec=179
        'acute',        # hex=0xb4 oct=0264 dec=180
        'mu',   # hex=0xb5 oct=0265 dec=181
        'paragraph',    # hex=0xb6 oct=0266 dec=182
        'periodcentered',       # hex=0xb7 oct=0267 dec=183
        'cedilla',      # hex=0xb8 oct=0270 dec=184
        'onesuperior',  # hex=0xb9 oct=0271 dec=185
        'ordmasculine', # hex=0xba oct=0272 dec=186
        'guillemotright',      # hex=0xbb oct=0273 dec=187
        'onequarter',   # hex=0xbc oct=0274 dec=188
        'onehalf',      # hex=0xbd oct=0275 dec=189
        'threequarters',        # hex=0xbe oct=0276 dec=190
        'questiondown', # hex=0xbf oct=0277 dec=191
        'Agrave',       # hex=0xc0 oct=0300 dec=192
        'Aacute',       # hex=0xc1 oct=0301 dec=193
        'Acircumflex',  # hex=0xc2 oct=0302 dec=194
        'Atilde',       # hex=0xc3 oct=0303 dec=195
        'Adieresis',    # hex=0xc4 oct=0304 dec=196
        'Aring',        # hex=0xc5 oct=0305 dec=197
        'AE',   # hex=0xc6 oct=0306 dec=198
        'Ccedilla',        # hex=0xc7 oct=0307 dec=199
        'Egrave',       # hex=0xc8 oct=0310 dec=200
        'Eacute',       # hex=0xc9 oct=0311 dec=201
        'Ecircumflex',  # hex=0xca oct=0312 dec=202
        'Edieresis',    # hex=0xcb oct=0313 dec=203
        'Igrave',       # hex=0xcc oct=0314 dec=204
        'Iacute',       # hex=0xcd oct=0315 dec=205
        'Icircumflex',  # hex=0xce oct=0316 dec=206
        'Idieresis',    # hex=0xcf oct=0317 dec=207
        'Eth',  # hex=0xd0 oct=0320 dec=208
        'Ntilde',       # hex=0xd1 oct=0321 dec=209
        'Ograve',       # hex=0xd2 oct=0322 dec=210
        'Oacute',       # hex=0xd3 oct=0323 dec=211
        'Ocircumflex',  # hex=0xd4 oct=0324 dec=212
        'Otilde',       # hex=0xd5 oct=0325 dec=213
        'Odieresis',    # hex=0xd6 oct=0326 dec=214
        'multiply',     # hex=0xd7 oct=0327 dec=215
        'Oslash',       # hex=0xd8 oct=0330 dec=216
        'Ugrave',       # hex=0xd9 oct=0331 dec=217
        'Uacute',       # hex=0xda oct=0332 dec=218
        'Ucircumflex',     # hex=0xdb oct=0333 dec=219
        'Udieresis',    # hex=0xdc oct=0334 dec=220
        'Yacute',       # hex=0xdd oct=0335 dec=221
        'Thorn',        # hex=0xde oct=0336 dec=222
        'germandbls',   # hex=0xdf oct=0337 dec=223
        'agrave',       # hex=0xe0 oct=0340 dec=224
        'aacute',       # hex=0xe1 oct=0341 dec=225
        'acircumflex',  # hex=0xe2 oct=0342 dec=226
        'atilde',       # hex=0xe3 oct=0343 dec=227
        'adieresis',    # hex=0xe4 oct=0344 dec=228
        'aring',        # hex=0xe5 oct=0345 dec=229
        'ae',   # hex=0xe6 oct=0346 dec=230
        'ccedilla',     # hex=0xe7 oct=0347 dec=231
        'egrave',       # hex=0xe8 oct=0350 dec=232
        'eacute',       # hex=0xe9 oct=0351 dec=233
        'ecircumflex',  # hex=0xea oct=0352 dec=234
        'edieresis',    # hex=0xeb oct=0353 dec=235
        'igrave',       # hex=0xec oct=0354 dec=236
        'iacute',       # hex=0xed oct=0355 dec=237
        'icircumflex',  # hex=0xee oct=0356 dec=238
        'idieresis',    # hex=0xef oct=0357 dec=239
        'eth',  # hex=0xf0 oct=0360 dec=240
        'ntilde',       # hex=0xf1 oct=0361 dec=241
        'ograve',       # hex=0xf2 oct=0362 dec=242
        'oacute',       # hex=0xf3 oct=0363 dec=243
        'ocircumflex',  # hex=0xf4 oct=0364 dec=244
        'otilde',       # hex=0xf5 oct=0365 dec=245
        'odieresis',    # hex=0xf6 oct=0366 dec=246
        'divide',       # hex=0xf7 oct=0367 dec=247
        'oslash',       # hex=0xf8 oct=0370 dec=248
        'ugrave',       # hex=0xf9 oct=0371 dec=249
        'uacute',       # hex=0xfa oct=0372 dec=250
        'ucircumflex',  # hex=0xfb oct=0373 dec=251
        'udieresis',    # hex=0xfc oct=0374 dec=252
        'yacute',      # hex=0xfd oct=0375 dec=253
        'thorn',        # hex=0xfe oct=0376 dec=254
        'ydieresis',    # hex=0xff oct=0377 dec=255
 );
@mac_enc = (
        '.notdef',      # hex=0x00 oct=0000 dec=0
        '.notdef',      # hex=0x01 oct=0001 dec=1
        '.notdef',      # hex=0x02 oct=0002 dec=2
        '.notdef',      # hex=0x03 oct=0003 dec=3
        '.notdef',      # hex=0x04 oct=0004 dec=4
        '.notdef',      # hex=0x05 oct=0005 dec=5
        '.notdef',      # hex=0x06 oct=0006 dec=6
        '.notdef',      # hex=0x07 oct=0007 dec=7
        '.notdef',      # hex=0x08 oct=0010 dec=8
        '.notdef',      # hex=0x09 oct=0011 dec=9
        '.notdef',      # hex=0x0a oct=0012 dec=10
        '.notdef',      # hex=0x0b oct=0013 dec=11
        '.notdef',      # hex=0x0c oct=0014 dec=12
        '.notdef',      # hex=0x0d oct=0015 dec=13
        '.notdef',      # hex=0x0e oct=0016 dec=14
        '.notdef',      # hex=0x0f oct=0017 dec=15
        '.notdef',      # hex=0x10 oct=0020 dec=16
        '.notdef',      # hex=0x11 oct=0021 dec=17
        '.notdef',      # hex=0x12 oct=0022 dec=18
        '.notdef',      # hex=0x13 oct=0023 dec=19
        '.notdef',      # hex=0x14 oct=0024 dec=20
        '.notdef',      # hex=0x15 oct=0025 dec=21
        '.notdef',      # hex=0x16 oct=0026 dec=22
        '.notdef',      # hex=0x17 oct=0027 dec=23
        '.notdef',      # hex=0x18 oct=0030 dec=24
        '.notdef',      # hex=0x19 oct=0031 dec=25
        '.notdef',      # hex=0x1a oct=0032 dec=26
        '.notdef',      # hex=0x1b oct=0033 dec=27
        '.notdef',      # hex=0x1c oct=0034 dec=28
        '.notdef',      # hex=0x1d oct=0035 dec=29
        '.notdef',      # hex=0x1e oct=0036 dec=30
        '.notdef',      # hex=0x1f oct=0037 dec=31
        'space',        # hex=0x20 oct=0040 dec=32
        'exclam',       # hex=0x21 oct=0041 dec=33
        'quotedbl',     # hex=0x22 oct=0042 dec=34
        'numbersign',   # hex=0x23 oct=0043 dec=35
        'dollar',       # hex=0x24 oct=0044 dec=36
        'percent',      # hex=0x25 oct=0045 dec=37
        'ampersand',    # hex=0x26 oct=0046 dec=38
        'quotesingle',  # hex=0x27 oct=0047 dec=39
        'parenleft',    # hex=0x28 oct=0050 dec=40
        'parenright',   # hex=0x29 oct=0051 dec=41
        'asterisk',     # hex=0x2a oct=0052 dec=42
        'plus', # hex=0x2b oct=0053 dec=43
        'comma',        # hex=0x2c oct=0054 dec=44
        'hyphen',       # hex=0x2d oct=0055 dec=45
        'period',       # hex=0x2e oct=0056 dec=46
        'slash',        # hex=0x2f oct=0057 dec=47
        'zero', # hex=0x30 oct=0060 dec=48
        'one',  # hex=0x31 oct=0061 dec=49
        'two',  # hex=0x32 oct=0062 dec=50
        'three',        # hex=0x33 oct=0063 dec=51
        'four', # hex=0x34 oct=0064 dec=52
        'five', # hex=0x35 oct=0065 dec=53
        'six',  # hex=0x36 oct=0066 dec=54
        'seven',        # hex=0x37 oct=0067 dec=55
        'eight',        # hex=0x38 oct=0070 dec=56
        'nine', # hex=0x39 oct=0071 dec=57
        'colon',        # hex=0x3a oct=0072 dec=58
        'semicolon',    # hex=0x3b oct=0073 dec=59
        'less', # hex=0x3c oct=0074 dec=60
        'equal',        # hex=0x3d oct=0075 dec=61
        'greater',      # hex=0x3e oct=0076 dec=62
        'question',     # hex=0x3f oct=0077 dec=63
        'at',   # hex=0x40 oct=0100 dec=64
        'A',    # hex=0x41 oct=0101 dec=65
        'B',    # hex=0x42 oct=0102 dec=66
        'C',    # hex=0x43 oct=0103 dec=67
        'D',    # hex=0x44 oct=0104 dec=68
        'E',    # hex=0x45 oct=0105 dec=69
        'F',    # hex=0x46 oct=0106 dec=70
        'G',    # hex=0x47 oct=0107 dec=71
        'H',    # hex=0x48 oct=0110 dec=72
        'I',    # hex=0x49 oct=0111 dec=73
        'J',    # hex=0x4a oct=0112 dec=74
        'K',    # hex=0x4b oct=0113 dec=75
        'L',    # hex=0x4c oct=0114 dec=76
        'M',    # hex=0x4d oct=0115 dec=77
        'N',    # hex=0x4e oct=0116 dec=78
        'O',    # hex=0x4f oct=0117 dec=79
        'P',    # hex=0x50 oct=0120 dec=80
        'Q',    # hex=0x51 oct=0121 dec=81
        'R',    # hex=0x52 oct=0122 dec=82
        'S',    # hex=0x53 oct=0123 dec=83
        'T',    # hex=0x54 oct=0124 dec=84
        'U',    # hex=0x55 oct=0125 dec=85
        'V',    # hex=0x56 oct=0126 dec=86
        'W',    # hex=0x57 oct=0127 dec=87
        'X',    # hex=0x58 oct=0130 dec=88
        'Y',    # hex=0x59 oct=0131 dec=89
        'Z',    # hex=0x5a oct=0132 dec=90
        'bracketleft',  # hex=0x5b oct=0133 dec=91
        'backslash',    # hex=0x5c oct=0134 dec=92
        'bracketright', # hex=0x5d oct=0135 dec=93
        'asciicircum',  # hex=0x5e oct=0136 dec=94
        'underscore',   # hex=0x5f oct=0137 dec=95
        'grave',        # hex=0x60 oct=0140 dec=96
        'a',    # hex=0x61 oct=0141 dec=97
        'b',    # hex=0x62 oct=0142 dec=98
        'c',    # hex=0x63 oct=0143 dec=99
        'd',    # hex=0x64 oct=0144 dec=100
        'e',    # hex=0x65 oct=0145 dec=101
        'f',    # hex=0x66 oct=0146 dec=102
        'g',    # hex=0x67 oct=0147 dec=103
        'h',    # hex=0x68 oct=0150 dec=104
        'i',    # hex=0x69 oct=0151 dec=105
        'j',    # hex=0x6a oct=0152 dec=106
        'k',    # hex=0x6b oct=0153 dec=107
        'l',    # hex=0x6c oct=0154 dec=108
        'm',    # hex=0x6d oct=0155 dec=109
        'n',    # hex=0x6e oct=0156 dec=110
        'o',    # hex=0x6f oct=0157 dec=111
        'p',    # hex=0x70 oct=0160 dec=112
        'q',    # hex=0x71 oct=0161 dec=113
        'r',    # hex=0x72 oct=0162 dec=114
        's',    # hex=0x73 oct=0163 dec=115
        't',    # hex=0x74 oct=0164 dec=116
        'u',    # hex=0x75 oct=0165 dec=117
        'v',    # hex=0x76 oct=0166 dec=118
        'w',    # hex=0x77 oct=0167 dec=119
        'x',    # hex=0x78 oct=0170 dec=120
        'y',    # hex=0x79 oct=0171 dec=121
        'z',    # hex=0x7a oct=0172 dec=122
        'braceleft',    # hex=0x7b oct=0173 dec=123
        'bar',  # hex=0x7c oct=0174 dec=124
        'braceright',   # hex=0x7d oct=0175 dec=125
        'asciitilde',   # hex=0x7e oct=0176 dec=126
        '.notdef',      # hex=0x7f oct=0177 dec=127
        'Adieresis',    # hex=0x80 oct=0200 dec=128
        'Aring',        # hex=0x81 oct=0201 dec=129
        'Ccedilla',     # hex=0x82 oct=0202 dec=130
        'Eacute',       # hex=0x83 oct=0203 dec=131
        'Ntilde',       # hex=0x84 oct=0204 dec=132
        'Odieresis',    # hex=0x85 oct=0205 dec=133
        'Udieresis',    # hex=0x86 oct=0206 dec=134
        'aacute',       # hex=0x87 oct=0207 dec=135
        'agrave',       # hex=0x88 oct=0210 dec=136
        'acircumflex',  # hex=0x89 oct=0211 dec=137
        'adieresis',    # hex=0x8a oct=0212 dec=138
        'atilde',       # hex=0x8b oct=0213 dec=139
        'aring',        # hex=0x8c oct=0214 dec=140
        'ccedilla',     # hex=0x8d oct=0215 dec=141
        'eacute',       # hex=0x8e oct=0216 dec=142
        'egrave',       # hex=0x8f oct=0217 dec=143
        'ecircumflex',  # hex=0x90 oct=0220 dec=144
        'edieresis',    # hex=0x91 oct=0221 dec=145
        'iacute',       # hex=0x92 oct=0222 dec=146
        'igrave',       # hex=0x93 oct=0223 dec=147
        'icircumflex',  # hex=0x94 oct=0224 dec=148
        'idieresis',    # hex=0x95 oct=0225 dec=149
        'ntilde',       # hex=0x96 oct=0226 dec=150
        'oacute',       # hex=0x97 oct=0227 dec=151
        'ograve',       # hex=0x98 oct=0230 dec=152
        'ocircumflex',  # hex=0x99 oct=0231 dec=153
        'odieresis',    # hex=0x9a oct=0232 dec=154
        'otilde',       # hex=0x9b oct=0233 dec=155
        'uacute',       # hex=0x9c oct=0234 dec=156
        'ugrave',       # hex=0x9d oct=0235 dec=157
        'ucircumflex',  # hex=0x9e oct=0236 dec=158
        'udieresis',    # hex=0x9f oct=0237 dec=159
        'dagger',       # hex=0xa0 oct=0240 dec=160
        'degree',       # hex=0xa1 oct=0241 dec=161
        'cent', # hex=0xa2 oct=0242 dec=162
        'sterling',     # hex=0xa3 oct=0243 dec=163
        'section',      # hex=0xa4 oct=0244 dec=164
        '.notdef',      # hex=0xa5 oct=0245 dec=165
        'paragraph',    # hex=0xa6 oct=0246 dec=166
        'germandbls',   # hex=0xa7 oct=0247 dec=167
        'registered',   # hex=0xa8 oct=0250 dec=168
        'copyright',    # hex=0xa9 oct=0251 dec=169
        'trademark',    # hex=0xaa oct=0252 dec=170
        'guillemotleft',        # hex=0xab oct=0253 dec=171
        'dieresis',     # hex=0xac oct=0254 dec=172
        '.notdef',      # hex=0xad oct=0255 dec=173
        'AE',   # hex=0xae oct=0256 dec=174
        'Oslash',       # hex=0xaf oct=0257 dec=175
        '.notdef',      # hex=0xb0 oct=0260 dec=176
        'plusminus',    # hex=0xb1 oct=0261 dec=177
        '.notdef',      # hex=0xb2 oct=0262 dec=178
        '.notdef',      # hex=0xb3 oct=0263 dec=179
        'yen',  # hex=0xb4 oct=0264 dec=180
        'mu',   # hex=0xb5 oct=0265 dec=181
        '266',  # hex=0xb6 oct=0266 dec=182
        'bullet',       # hex=0xb7 oct=0267 dec=183
        '313',  # hex=0xb8 oct=0270 dec=184
        '~W',   # hex=0xb9 oct=0271 dec=185
        '353',  # hex=0xba oct=0272 dec=186
        'ordfeminine',  # hex=0xbb oct=0273 dec=187
        'ordmasculine', # hex=0xbc oct=0274 dec=188
        '~W',   # hex=0xbd oct=0275 dec=189
        'ae',   # hex=0xbe oct=0276 dec=190
        'oslash',       # hex=0xbf oct=0277 dec=191
        'questiondown', # hex=0xc0 oct=0300 dec=192
        'exclamdown',   # hex=0xc1 oct=0301 dec=193
        'logicalnot',   # hex=0xc2 oct=0302 dec=194
        '.notdef',      # hex=0xc3 oct=0303 dec=195
        'florin',       # hex=0xc4 oct=0304 dec=196
        '.notdef',      # hex=0xc5 oct=0305 dec=197
        '.notdef',      # hex=0xc6 oct=0306 dec=198
        '.notdef',      # hex=0xc7 oct=0307 dec=199
        '.notdef',      # hex=0xc8 oct=0310 dec=200
        'ellipsis',     # hex=0xc9 oct=0311 dec=201
        '.notdef',      # hex=0xca oct=0312 dec=202
        'Agrave',       # hex=0xcb oct=0313 dec=203
        'Atilde',       # hex=0xcc oct=0314 dec=204
        'Otilde',       # hex=0xcd oct=0315 dec=205
        'OE',   # hex=0xce oct=0316 dec=206
        'oe',   # hex=0xcf oct=0317 dec=207
        'endash',       # hex=0xd0 oct=0320 dec=208
        'emdash',       # hex=0xd1 oct=0321 dec=209
        'quotedblleft', # hex=0xd2 oct=0322 dec=210
        'quotedblright',        # hex=0xd3 oct=0323 dec=211
        'quoteleft',    # hex=0xd4 oct=0324 dec=212
        'quoteright',   # hex=0xd5 oct=0325 dec=213
        'divide',       # hex=0xd6 oct=0326 dec=214
        '~W',   # hex=0xd7 oct=0327 dec=215
        'ydieresis',    # hex=0xd8 oct=0330 dec=216
        'Ydieresis',    # hex=0xd9 oct=0331 dec=217
        'fraction',     # hex=0xda oct=0332 dec=218
        '.notdef',      # hex=0xdb oct=0333 dec=219
        'guilsinglleft',        # hex=0xdc oct=0334 dec=220
        'guilsinglright',       # hex=0xdd oct=0335 dec=221
        'fi',   # hex=0xde oct=0336 dec=222
        'fl',   # hex=0xdf oct=0337 dec=223
        'daggerdbl',    # hex=0xe0 oct=0340 dec=224
        'periodcentered',       # hex=0xe1 oct=0341 dec=225
        'quotesinglbase',       # hex=0xe2 oct=0342 dec=226
        'quotedblbase', # hex=0xe3 oct=0343 dec=227
        'perthousand',  # hex=0xe4 oct=0344 dec=228
        '~W',   # hex=0xe5 oct=0345 dec=229
        'Ecircumflex',  # hex=0xe6 oct=0346 dec=230
        '~W',   # hex=0xe7 oct=0347 dec=231
        'Edieresis',    # hex=0xe8 oct=0350 dec=232
        'Egrave',       # hex=0xe9 oct=0351 dec=233
        'Iacute',       # hex=0xea oct=0352 dec=234
        'Icircumflex',  # hex=0xeb oct=0353 dec=235
        'Idieresis',    # hex=0xec oct=0354 dec=236
        'Igrave',       # hex=0xed oct=0355 dec=237
        'Oacute',       # hex=0xee oct=0356 dec=238
        'Ocircumflex',  # hex=0xef oct=0357 dec=239
        '.notdef',      # hex=0xf0 oct=0360 dec=240
        '~W',   # hex=0xf1 oct=0361 dec=241
        '~W',   # hex=0xf2 oct=0362 dec=242
        '~W',   # hex=0xf3 oct=0363 dec=243
        '~W',   # hex=0xf4 oct=0364 dec=244
        'dotlessi',     # hex=0xf5 oct=0365 dec=245
        'circumflex',   # hex=0xf6 oct=0366 dec=246
        'tilde',        # hex=0xf7 oct=0367 dec=247
        'macron',       # hex=0xf8 oct=0370 dec=248
        'breve',        # hex=0xf9 oct=0371 dec=249
        'dotaccent',    # hex=0xfa oct=0372 dec=250
        'ring', # hex=0xfb oct=0373 dec=251
        'cedilla',      # hex=0xfc oct=0374 dec=252
        'hungarumlaut', # hex=0xfd oct=0375 dec=253
        'ogonek',       # hex=0xfe oct=0376 dec=254
        'caron',        # hex=0xff oct=0377 dec=255
 );
@std_enc=qw(
  .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef 
  space exclam quotedbl numbersign dollar percent ampersand quoteright 
  parenleft parenright asterisk plus comma hyphen period slash zero 
  one two three four five six seven eight nine colon semicolon less 
  equal greater question at A B C D E F G H I J K L M N O P Q R S T U 
  V W X Y Z bracketleft backslash bracketright asciicircum underscore 
  quoteleft a b c d e f g h i j k l m n o p q r s t u v w x y z 
  braceleft bar braceright asciitilde .notdef .notdef .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef exclamdown cent 
  sterling fraction yen florin section currency quotesingle 
  quotedblleft guillemotleft guilsinglleft guilsinglright fi fl 
  .notdef endash dagger daggerdbl periodcentered .notdef paragraph 
  bullet quotesinglbase quotedblbase quotedblright guillemotright 
  ellipsis perthousand .notdef questiondown .notdef grave acute 
  circumflex tilde macron breve dotaccent dieresis .notdef ring 
  cedilla .notdef hungarumlaut ogonek caron emdash .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef 
  .notdef .notdef .notdef .notdef .notdef .notdef AE .notdef 
  ordfeminine .notdef .notdef .notdef .notdef Lslash Oslash OE 
  ordmasculine .notdef .notdef .notdef .notdef .notdef ae .notdef 
  .notdef .notdef dotlessi .notdef .notdef lslash oslash oe germandbls 
  .notdef .notdef .notdef .notdef
);
@latin1_enc=qw(
	.notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef
	.notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef
	.notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef
	.notdef .notdef .notdef .notdef .notdef .notdef .notdef .notdef
	space exclam quotedbl numbersign dollar percent ampersand quotesingle
	parenleft parenright asterisk plus comma hyphen period slash
	zero one two three four five six seven eight nine colon semicolon
	less equal greater question at A B C D E F G H I J K L M N O P Q
	R S T U V W X Y Z bracketleft backslash bracketright asciicircum
	underscore grave a b c d e f g h i j k l m n o p q r s t u v w x
	y z braceleft bar braceright asciitilde bullet
	Euro bullet quotesinglbase florin quotedblbase ellipsis dagger daggerdbl circumflex perthousand Scaron guilsinglleft OE bullet Zcaron bullet
  	bullet quoteleft quoteright quotedblleft quotedblright
        bullet endash emdash tilde trademark scaron guilsinglright oe bullet zcaron Ydieresis space
	exclamdown cent sterling currency yen brokenbar section dieresis copyright
	ordfeminine guillemotleft logicalnot hyphen registered macron
	degree plusminus twosuperior threesuperior acute mu paragraph
	periodcentered cedilla onesuperior ordmasculine guillemotright
	onequarter onehalf threequarters questiondown Agrave Aacute Acircumflex
	Atilde Adieresis Aring AE Ccedilla Egrave Eacute Ecircumflex
	Edieresis Igrave Iacute Icircumflex Idieresis Eth Ntilde Ograve
	Oacute Ocircumflex Otilde Odieresis multiply Oslash Ugrave Uacute
	Ucircumflex Udieresis Yacute Thorn germandbls agrave aacute acircumflex
	atilde adieresis aring ae ccedilla egrave eacute ecircumflex edieresis
	igrave iacute icircumflex idieresis eth ntilde ograve oacute ocircumflex
	otilde odieresis divide oslash ugrave uacute ucircumflex udieresis
	yacute thorn ydieresis
);
}

1;
__END__

