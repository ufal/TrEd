#=======================================================================
#  ____  ____  _____              _    ____ ___   ____
# |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
# | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
# |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
# |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
# Copyright 1999-2001 Alfred Reibenschuh <areibens@cpan.org>.
#
# This library is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.
#
#=======================================================================
#
# PDF::API2::Text
#
#=======================================================================
package PDF::API2::Text;

use strict;
use vars qw(@ISA $VERSION);
@ISA = qw(PDF::API2::Content);
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;


use PDF::API2::Content;
use PDF::API2::Gfx;
use PDF::API2::PDF::Utils;
use PDF::API2::Util;
use Math::Trig;

=head2 PDF::API2::Text

Subclassed from PDF::API2::Content.

=item $txt = PDF::API2::Text->new @parameters

Returns a new text content object (called from $page->text).

=cut

sub new {
  my ($class)=@_;
  my $self = $class->SUPER::new(@_);
  $self->add('BT');
  $self->{' font'}=undef;
  $self->{' fontsize'}=0;
  $self->{' charspace'}=0;
  $self->{' hspace'}=100;
  $self->{' wordspace'}=0;
  $self->{' lead'}=0;
  $self->{' rise'}=0;
  $self->{' render'}=0;
  $self->{' matrix'}=[1,0,0,1,0,0];
  $self->{' fillcolor'}=[0];
  $self->{' strokecolor'}=[0];
  $self->{' translate'}=[0,0];
  $self->{' scale'}=[1,1];
  $self->{' skew'}=[0,0];
  $self->{' rotate'}=0;
  return($self);
}

=item %state = $txt->textstate %state

Sets or gets the current text-object state.

=cut

sub textstate {
  my $self=shift @_;
  my %state;
  if(scalar @_) {
    %state=@_;
    foreach my $k (qw( charspace hspace wordspace lead rise render )) {
      next unless($state{$k});
      eval " \$self->$k(\$state{\$k}); ";
    }
    if($state{font} && $state{fontsize}) {
      $self->font($state{font},$state{fontsize});
    }
    if($state{matrix}) {
      $self->matrix(@{$state{matrix}});
      @{$self->{' translate'}}=@{$state{translate}};
      $self->{' rotate'}=$state{rotate};
      @{$self->{' scale'}}=@{$state{scale}};
      @{$self->{' skew'}}=@{$state{skew}};
    }
    if($state{fillcolor}) {
      $self->fillcolor(@{$state{fillcolor}});
    }
    if($state{strokecolor}) {
      $self->strokecolor(@{$state{strokecolor}});
    }
    %state=();
  } else {
    foreach my $k (qw( font fontsize charspace hspace wordspace lead rise render )) {
      $state{$k}=$self->{" $k"};
    }
    $state{matrix}=[@{$self->{" matrix"}}];
    $state{rotate}=$self->{" rotate"};
    $state{scale}=[@{$self->{" scale"}}];
    $state{skew}=[@{$self->{" skew"}}];
    $state{translate}=[@{$self->{" translate"}}];
    $state{fillcolor}=[@{$self->{" fillcolor"}}];
    $state{strokecolor}=[@{$self->{" strokecolor"}}];
  }
  return(%state);
}

=item ($tx,$ty) = $txt->textpos

Gets the current estimated text position.

=cut

sub textpos {
  my $self=shift @_;
  my (@m)=$self->matrix;
  return($m[4],$m[5]);
}

=item $txt->matrix $a, $b, $c, $d, $e, $f

Sets the matrix.

B<PLEASE NOTE:> This method is not expected to be called by the user
and else will 'die'. This was implemented to keep proper state in the
text-object, so please use transform, transform_rel, translate, scale,
skew or rotate instead.

=cut

sub matrix {
  my $self=shift @_;
  my $cl=caller;
  my @cl=caller;
  die sprintf("unauthorized call from package=%s,file=%s,line=%i",@cl) if($cl !~ /^PDF::API2/);
  if(scalar @_) {
    my ($a,$b,$c,$d,$e,$f)=@_;
    $self->add((floats($a,$b,$c,$d,$e,$f)),'Tm');
    @{$self->{' matrix'}}=($a,$b,$c,$d,$e,$f);
  }
  return(@{$self->{' matrix'}});
}

sub transform {
  my ($self,%opt)=@_;
  $self->SUPER::transform(%opt);
  if($opt{-translate}) {
    @{$self->{' translate'}}=@{$opt{-translate}};
  } else {
    @{$self->{' translate'}}=(0,0);
  }
  if($opt{-rotate}) {
    $self->{' rotate'}=$opt{-rotate};
  } else {
    $self->{' rotate'}=0;
  }
  if($opt{-scale}) {
    @{$self->{' scale'}}=@{$opt{-scale}};
  } else {
    @{$self->{' scale'}}=(1,1);
  }
  if($opt{-skew}) {
    @{$self->{' skew'}}=@{$opt{-skew}};
  } else {
    @{$self->{' skew'}}=(0,0);
  }
  return($self);
}

sub translate {
  my ($self,$x,$y)=@_;
  $self->transform(-translate=>[$x,$y]);
}

sub scale {
  my ($self,$sx,$sy)=@_;
  $self->transform(-scale=>[$sx,$sy]);
}

sub skew {
  my ($self,$a,$b)=@_;
  $self->transform(-skew=>[$a,$b]);
}

sub rotate {
  my ($self,$a)=@_;
  $self->transform(-rotate=>$a);
}

=item $txt->transform_rel %opts

Sets transformations (eg. translate, rotate, scale, skew) in pdf-canonical order,
but relative to the previously set values.

B<Example:>

  $txt->transform_rel(
    -translate => [$x,$y],
    -rotate    => $rot,
    -scale     => [$sx,$sy],
    -skew      => [$sa,$sb],
  )

=cut

sub transform_rel {
  my ($self,%opt)=@_;
  my ($sa1,$sb1)=@{$opt{-skew} ? $opt{-skew} : [0,0]};
  my ($sa0,$sb0)=@{$self->{" skew"}};


  my ($sx1,$sy1)=@{$opt{-scale} ? $opt{-scale} : [1,1]};
  my ($sx0,$sy0)=@{$self->{" scale"}};

  my $rot1=$opt{"-rotate"} || 0;
  my $rot0=$self->{" rotate"};

  my ($tx1,$ty1)=@{$opt{-translate} ? $opt{-translate} : [0,0]};
  my ($tx0,$ty0)=@{$self->{" translate"}};

  $self->transform(
    -skew=>[$sa0+$sa1,$sb0+$sb1],
    -scale=>[$sx0*$sx1,$sy0*$sy1],
    -rotate=>$rot0+$rot1,
    -translate=>[$tx0+$tx1,$ty0+$ty1],
  );
  return($self);
}

sub matrix_update {
  use PDF::API2::Matrix;
  my ($self,$tx,$ty)=@_;
  my ($a,$b,$c,$d,$e,$f)=$self->matrix;
  my $mtx=PDF::API2::Matrix->new([$a,$b,0],[$c,$d,0],[$e,$f,1]);
  my $tmtx=PDF::API2::Matrix->new([$tx,$ty,1]);
  $tmtx=$tmtx->multiply($mtx);
  @{$self->{' matrix'}}=(
    $a,$b,
    $c,$d,
    $tmtx->[0][0],$tmtx->[0][1]
  );
  @{$self->{' translate'}}=($tmtx->[0][0],$tmtx->[0][1]);
  return($self);
}

sub outobjdeep {
  my ($self, @opts) = @_;
  $self->add('ET') if(ref($self) eq 'PDF::API2::Text');
  foreach my $k (qw/ api apipdf apipage font fontsize charspace hspace wordspace lead rise render matrix fillcolor strokecolor translate scale skew rotate /) {
    $self->{" $k"}=undef;
    delete($self->{" $k"});
  }
  $self->SUPER::outobjdeep(@opts);
}

=item $txt->font $fontobj,$size

=cut

sub font {
  my ($self,$font,$size)=@_;
  $self->{' font'}=$font;
  $self->{' fontsize'}=$size;
  $self->add("/".$font->{' apiname'},float($size),'Tf');

  $self->resource('Font',$font->{' apiname'},$font);

  return($self);
}

=item $spacing = $txt->charspace $spacing

=cut

sub charspace {
  my ($self,$para)=@_;
  if(defined $para) {
    $self->{' charspace'}=$para;
    $self->add(float($para,6),'Tc');
  }
  return $self->{' charspace'};
}

=item $spacing = $txt->wordspace $spacing

=cut

sub wordspace {
  my ($self,$para)=@_;
  if(defined $para) {
    $self->{' wordspace'}=$para;
    $self->add(float($para,6),'Tw');
  }
  return $self->{' wordspace'};
}

=item $spacing = $txt->hspace $spacing

=cut

sub hspace {
  my ($self,$para)=@_;
  if(defined $para) {
    $self->{' hspace'}=$para;
    $self->add(float($para,6),'Tz');
  }
  return $self->{' hspace'};
}

=item $leading = $txt->lead $leading

=cut

sub lead {
        my ($self,$para)=@_;
        if (defined ($para)) {
                $self->{' lead'} = $para;
                $self->add(float($para),'TL');
        }
        return $self->{' lead'};
}

=item $rise = $txt->rise $rise

=cut

sub rise {
        my ($self,$para)=@_;
        if (defined ($para)) {
                $self->{' rise'} = $para;
                $self->add(float($para),'Ts');
        }
        return $self->{' rise'};
}

=item $rendering = $txt->render $rendering

=cut

sub render {
  my ($self,$para)=@_;
        if (defined ($para)) {
                $self->{' render'} = $para;
    $self->add(intg($para),'Tr');
        }
        return $self->{' render'};
}

=item $txt->cr $linesize

takes an optional argument giving a custom leading between lines.

=cut

sub cr {
  my ($self,$para)=@_;
  if(defined($para)) {
    $self->add(0,float($para),'Td');
    $self->matrix_update(0,$para);
  } else {
    $self->add('T*');
    $self->matrix_update(0,$self->lead);
  }
}

=item $txt->nl

=cut

sub nl {
  my ($self,$width)=@_;
  $self->add('T*');
  $self->matrix_update(-($width||0),$self->lead);
}

=item $txt->distance $dx,$dy

=cut

sub distance {
  my ($self,$dx,$dy)=@_;
  $self->add(float($dx),float($dy),'Td');
  $self->matrix_update($dx,$dy);
}

=item $width = $txt->advancewidth $string

Returns the width of the string based on all currently set text-attributes.

=cut

sub advancewidth {
  my ($self,$text,%opt)=@_;
  my @txt;
  my $spacer;
  if($opt{-ucs2}) {
    @txt=split(/\x00\x20/,$text);
    $spacer="\x00\x20";
  } else {
    @txt=split(/\s+/,$text);
    $spacer=" ";
  }
  my $num_space=(scalar @txt)-1;
  $text=join($spacer,@txt);
  my $num_char=length($text);
  my $glyph_width=0;
  $glyph_width=$self->{' font'}->width($text,%opt)*$self->{' fontsize'};
  my $word_spaces=$self->wordspace*$num_space;
  my $char_spaces=$self->charspace*$num_char;
  my $advance=($glyph_width+$word_spaces+$char_spaces)*$self->{' hspace'}/100;
  return $advance;
}

=item $width = $txt->text $text, %options

Applys text to the content and optionally returns the width of the given text.

You can use the -utf8 option to give the text in utf8.

=cut

sub text {
  my ($self,$text,%opt)=@_;
  my $wd=0;
  my @txt;
  if(! $opt{-ucs2}) {
    @txt=split(/\s+/,$text);
    $text=join(' ',@txt);
  }
  if(defined $opt{-indent}) {
    if($opt{-utf8}){
      $self->add('[',(-$opt{-indent}*(1000/$self->{' fontsize'})*(100/$self->hspace)),$self->{' font'}->text_utf8($text),']','TJ');
    } elsif($opt{-ucs2}){
      $self->add('[',(-$opt{-indent}*(1000/$self->{' fontsize'})*(100/$self->hspace)),$self->{' font'}->text_ucs2($text),']','TJ');
    } else {
      $self->add('[',(-$opt{-indent}*(1000/$self->{' fontsize'})*(100/$self->hspace)),$self->{' font'}->text($text),']','TJ');
    }
    $wd=$self->advancewidth($text,%opt)+$opt{-indent};
  } else {
    if($opt{-utf8}){
      $self->add($self->{' font'}->text_utf8($text),'Tj');
    } elsif($opt{-ucs2}){
      $self->add($self->{' font'}->text_ucs2($text),'Tj');
    } else {
      $self->add($self->{' font'}->text($text),'Tj');
    }
    $wd=$self->advancewidth($text,%opt);
  }

  $self->matrix_update($wd,0);
  return($wd);
}

sub text_fancy {
  my ($self,$text,%opt)=@_;
  my %state1=();
  my %state2=();
  my $wd=0;
  my @txt;
  if(! $opt{-ucs2}) {
    @txt=split(/\s+/,$text);
    $text=join(' ',@txt);
  }
  if((defined $opt{-font})
    || (defined $opt{-size})
    || (defined $opt{-color})
    || (defined $opt{-underline})
  ) {
    %state1=$self->textstate;

    # look into font options
    if(defined $opt{-font} && defined $opt{-size}) {
      $self->font($opt{-font},$opt{-size});
    } elsif(defined $opt{-font}) {
      $self->font($opt{-font},$self->{' fontsize'});
    } elsif(defined $opt{-size}) {
      $self->font($self->{' font'},$opt{-size});
    }

    $self->fillcolor(@{$opt{-color}}) if(defined $opt{-color});

    %state2=$self->textstate;

    if(defined $opt{-underline}) {
      if(defined $opt{-indent}) {
        $self->matrix_update($opt{-indent},0);
      }
      my $wd=$self->advancewidth($text,%opt);
      if($wd) {
        my ($x1,$y1)=$self->textpos;
        $self->matrix_update($wd,0);
        my ($x2,$y2)=$self->textpos;

        my $x3=$x1+(($y2-$y1)/$wd)*($self->{' font'}->underlineposition*$self->{' fontsize'}/1000);
        my $y3=$y1+(($x2-$x1)/$wd)*($self->{' font'}->underlineposition*$self->{' fontsize'}/1000);

        my $x4=$x3+($x2-$x1);
        my $y4=$y3+($y2-$y1);
        $self->add('ET');
        PDF::API2::Content::save($self);
        PDF::API2::Content::linewidth($self,$opt{-underline});
        PDF::API2::Content::strokecolor($self,@{$state2{fillcolor}});
        PDF::API2::Gfx::move($self,$x3,$y3);
        PDF::API2::Gfx::line($self,$x4,$y4);
        PDF::API2::Gfx::stroke($self);
        PDF::API2::Content::restore($self);
        $self->add('BT');
        $self->textstate(%state2);
      }
    }
  }
  $wd=$self->text($text,%opt);
  if((defined $opt{-font})
    || (defined $opt{-size})
    || (defined $opt{-color})
    || (defined $opt{-underline})
  ) {
    delete $state1{matrix};
    delete $state1{rotate};
    delete $state1{scale};
    delete $state1{skew};
    delete $state1{translate};
    $self->textstate(%state1);
  }
  return($wd);
}

=item $txt->text_center $text, %options

You can use the -utf8 option to give the text in utf8.

=cut

sub text_center {
  my ($self,$text,%opt)=@_;
  my $width=$self->advancewidth($text,%opt);
  return $self->text($text,-indent=>-($width/2),%opt);
}

=item $txt->text_right $text, %options

You can use the -utf8 option to give the text in utf8.

=cut

sub text_right {
  my ($self,$text,%opt)=@_;
  my $width=$self->advancewidth($text,%opt);
  return $self->text($text,-indent=>-$width,%opt);
}

=item ($width, $overflow) = $txt->text_justify $text , -width => $width [, %options ]

If -overflow is given, $overflow will contain any text, which wont
fit into width without exessive scaling.

If -underflow is given, and $text is smaller than $width
the text will be typeset using $txt->text.

if -less is given, text overflow will be calculated using minimal number of words.

You can use the -utf8 option to give the text in utf8.

The returned width is that of the typeset text.

=cut

sub text_justify {
  my ($self,$text,%opts)=@_;

  my @texts;
  my $spacer;

  if($opts{-ucs2}) {
    @texts=split(/\x00\x20/,$text);
    $spacer="\x00\x20";
  } else {
    @texts=split(/\s+/,$text);
    $spacer=" ";
  }

  $text=join($spacer,@texts);
  my ($overflow,$ofw);
  my $indent=$opts{-indent}||0;
  if($opts{-overflow}) {
    my @linetext=();
    while(($self->advancewidth(join($spacer,@linetext),%opts) < ($opts{-width}-$indent)) && scalar @texts){
      push @linetext, shift @texts;
    }
    if($opts{-less} && (scalar @linetext > 1) && ($self->advancewidth(join($spacer,@linetext),%opts) > ($opts{-width}-$indent))) {
      unshift @texts, pop @linetext;
    }
    $overflow=join($spacer,@texts);
    $text=join($spacer,@linetext);
  } else {
    $overflow='';
    $text=join($spacer,@texts);
  }

  if($opts{-test}) {
    if($opts{-underflow}
      && ($self->advancewidth($text,%opts) < ($opts{-width}-$indent))
      && (length($overflow)==0)
    ) {
      $ofw=$indent+$self->advancewidth($text,%opts);
    } else {
      $ofw=$opts{-width};
    }
  } else {
    if($opts{-underflow}
      && ($self->advancewidth($text,%opts) < ($opts{-width}-$indent))
      && (length($overflow)==0)
    ) {
      $ofw=$indent+$self->advancewidth($text,%opts);
      $self->text($text,%opts);
      return ($ofw,'');
    } else {
      $ofw=$opts{-width};
    }

    my @wds=$self->{' font'}->width_array($text,%opts);
    my $swt=$self->{' font'}->width(' ');
    my $wth=$self->advancewidth($text,%opts);

    my $hs=$self->hspace;
    $self->hspace($hs*($opts{-width}-$indent)/$wth) unless($opts{-left});
    $ofw=$self->text($text,%opts);
    $self->hspace($hs);
  }
  return ($ofw,$overflow);
}

=item ($w,$y,$text) = $txt->paragraph  $text, %options,
-x => $xorg,
-y => $yorg,
-w => $width,
-h => $height,
-flindent => $firstlineindent,
-lead => $lead

You can use the -utf8 option to give the text in utf8.

  $w ... witdth of the text on the last line.
  $y ... y-coord of the last line.
  $text ... any left-over text which did not fit into the paragraph

You must give the -rel option if you require awareness of previously
set relative transformations.

=cut

sub paragraph {
  my ($self,$text,%opt)=@_;
  my $x=$opt{-x}||0;
  my $y=$opt{-y}||0;
  my $ht=$opt{-h}||0;
  my $wd=$opt{-w}||0;
  my $flidt=$opt{-flindent}||0;
  my $idt=$flidt;
  my $h=$ht;
  my $sz=$self->{' fontsize'};
  my @txt;
  my $spacer;

  $self->lead($opt{-lead} || $self->lead() || -$sz);

  if($opt{-rel}) {
    $self->transform_rel(-translate=>[$x,$y]);
  } else {
    $self->translate($x,$y);
  }
  $ht+=$self->lead();
  my $ofw=0;
  my $first=1;
  while( ($ht>0) && (length($text)>0) ) {
    ($ofw,$text)=$self->text_justify($text,-width=>$wd,-indent=>($first?$flidt:0),-overflow=>1,-less=>1,-underflow=>1,%opt);
    $self->transform_rel(-translate=>[-$ofw,$self->lead()]) if(length($text)>0);
    $ht+=$self->lead() if(length($text)>0);
    $first=0;
  }
  return( $ofw,$y+$ht-$h,$text);
}

sub fillcolor {
  my $self=shift @_;
  if(scalar @_) {
    $self->SUPER::fillcolor(@_);
    @{$self->{' fillcolor'}}=@_;
  }
  return(@{$self->{' fillcolor'}});
}

sub strokecolor {
  my $self=shift @_;
  if(scalar @_) {
    $self->SUPER::strokecolor(@_);
    @{$self->{' strokecolor'}}=@_;
  }
  return(@{$self->{' strokecolor'}});
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
