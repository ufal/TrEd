#=======================================================================
#    ____  ____  _____              _    ____ ___   ____
#   |  _ \|  _ \|  ___|  _   _     / \  |  _ \_ _| |___ \
#   | |_) | | | | |_    (_) (_)   / _ \ | |_) | |    __) |
#   |  __/| |_| |  _|    _   _   / ___ \|  __/| |   / __/
#   |_|   |____/|_|     (_) (_) /_/   \_\_|  |___| |_____|
#
#   Copyright 1999-2001 Alfred Reibenschuh <areibens@cpan.org>.
#
#   This library is free software; you can redistribute it 
#   and/or modify it under the same terms as Perl itself.
#
#=======================================================================
#
#   PDF::API2::Page
#
#=======================================================================
package PDF::API2::Page;

use strict;
use vars qw(@ISA %pgsz $VERSION);
@ISA = qw(PDF::API2::PDF::Pages);
use PDF::API2::PDF::Pages;
use PDF::API2::PDF::Utils;

use PDF::API2::Util;

use Math::Trig;
( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;


=head2 PDF::API2::Page

Subclassed from PDF::API2::PDF::Pages

=item $page = PDF::API2::Page->new $pdf, $parent, $index

Returns a page object (called from $pdf->page).

=cut

sub new {
    my ($class, $pdf, $parent, $index) = @_;
    my ($self) = {};

    $class = ref $class if ref $class;
    $self = $class->SUPER::new($pdf, $parent);
    $self->{'Type'} = PDFName('Page');
    delete $self->{'Count'};
    delete $self->{'Kids'};
    $parent->add_page($self, $index);
    $self;
}

%pgsz=(
    '4a'        =>  [ 4760  , 6716  ],
    '2a'        =>  [ 3368  , 4760  ],
    'a0'        =>  [ 2380  , 3368  ],
    'a1'        =>  [ 1684  , 2380  ],
    'a2'        =>  [ 1190  , 1684  ],
    'a3'        =>  [ 842   , 1190  ],
    'a4'        =>  [ 595   , 842   ],
    'a5'        =>  [ 421   , 595   ],
    'a6'        =>  [ 297   , 421   ],
    '4b'        =>  [ 5656  , 8000  ],
    '2b'        =>  [ 4000  , 5656  ],
    'b0'        =>  [ 2828  , 4000  ],
    'b1'        =>  [ 2000  , 2828  ],
    'b2'        =>  [ 1414  , 2000  ],
    'b3'        =>  [ 1000  , 1414  ],
    'b4'        =>  [ 707   , 1000  ],
    'b5'        =>  [ 500   , 707   ],
    'b6'        =>  [ 353   , 500   ],
    'letter'    =>  [ 612   , 792   ],
    'broadsheet'    =>  [ 1296  , 1584  ],
    'ledger'    =>  [ 1224  , 792   ],
    'tabloid'   =>  [ 792   , 1224  ],
    'legal'     =>  [ 612   , 1008  ],
    'executive' =>  [ 522   , 756   ],
    '36x36'     =>  [ 2592  , 2592  ],
);

sub _pagesize {
    my $s=shift @_;
    if($pgsz{lc($s)}) {
        return @{$pgsz{lc($s)}};
    } elsif($s=~/^[\d\.]+$/) {
        return($s,$s);
    } else {
        return(595,842);
    }
}

=item $page = PDF::API2::Page->coerce $pdf, $pdfpage

Returns a page object converted from $pdfpage (called from $pdf->openpage).

=cut

sub coerce {
    my ($class, $pdf, $page) = @_;
    my ($self) = {};
    bless($self,$class);
    foreach my $k (keys %{$page}) {
        $self->{$k}=$page->{$k};
    }
    $self->{' apipdf'}=$pdf;
    return($self);
}

=item $page->update

Marks a page to be updated (by $pdf->update).

=cut

sub update {
    my ($self) = @_;
    $self->{' apipdf'}->out_obj($self);
    $self;
}

=item $page->mediabox $w, $h

=item $page->mediabox $llx, $lly, $urx, $ury

=item $page->mediabox $alias

Sets the mediabox.  This method supports the following aliases: 
'4A', '2A', 'A0', 'A1', 'A2', 'A3', 'A4', 'A5', 'A6', 
'4B', '2B', 'B0', 'B1', 'B2', 'B3', 'B4', 'B5', 'B6', 
'LETTER', 'BROADSHEET', 'LEDGER', 'TABLOID', 'LEGAL', 
'EXECUTIVE', and '36X36'.

=cut

sub mediabox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    if(defined $x2) {
        $self->{'MediaBox'}=PDFArray(
            map { PDFNum(float($_)) } ($x1,$y1,$x2,$y2)
        );
    } elsif(defined $y1) {
        $self->{'MediaBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,$x1,$y1)
        );
    } else {
        $self->{'MediaBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,_pagesize($x1))
        );
    }
    return($self);
}

=item $page->cropbox $w, $h

=item $page->cropbox $llx, $lly, $urx, $ury

=item $page->cropbox $alias

Sets the cropbox.  This method supports the same aliases as mediabox.

=cut

sub cropbox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    if(defined $x2) {
        $self->{'CropBox'}=PDFArray(
            map { PDFNum(float($_)) } ($x1,$y1,$x2,$y2)
        );
    } elsif(defined $y1) {
        $self->{'CropBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,$x1,$y1)
        );
    } else {
        $self->{'CropBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,_pagesize($x1))
        );
    }
    $self;
}

=item $page->bleedbox $w, $h

=item $page->bleedbox $llx, $lly, $urx, $ury

=item $page->bleedbox $alias

Sets the bleedbox.  This method supports the same aliases as mediabox.

=cut

sub bleedbox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    if(defined $x2) {
        $self->{'BleedBox'}=PDFArray(
            map { PDFNum(float($_)) } ($x1,$y1,$x2,$y2)
        );
    } elsif(defined $y1) {
        $self->{'BleedBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,$x1,$y1)
        );
    } else {
        $self->{'BleedBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,_pagesize($x1))
        );
    }
    $self;
}

=item $page->trimbox $w, $h

=item $page->trimbox $llx, $lly, $urx, $ury

Sets the trimbox.  This method supports the same aliases as mediabox.

=cut

sub trimbox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    if(defined $x2) {
        $self->{'TrimBox'}=PDFArray(
            map { PDFNum(float($_)) } ($x1,$y1,$x2,$y2)
        );
    } elsif(defined $y1) {
        $self->{'TrimBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,$x1,$y1)
        );
    } else {
        $self->{'TrimBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,_pagesize($x1))
        );
    }
    $self;
}

=item $page->artbox $w, $h

=item $page->artbox $llx, $lly, $urx, $ury

=item $page->artbox $alias

Sets the artbox.  This method supports the same aliases as mediabox.

=cut

sub artbox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    if(defined $x2) {
        $self->{'ArtBox'}=PDFArray(
            map { PDFNum(float($_)) } ($x1,$y1,$x2,$y2)
        );
    } elsif(defined $y1) {
        $self->{'ArtBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,$x1,$y1)
        );
    } else {
        $self->{'ArtBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,_pagesize($x1))
        );
    }
    $self;
}

=item $gfx = $page->gfx

Returns a graphics content object.

=cut

sub fixcontents {
    my ($self) = @_;
        $self->{'Contents'} = $self->{'Contents'} || PDFArray();
        if(ref($self->{'Contents'})=~/Objind$/) {
        $self->{'Contents'}->realise;
    }
        if(ref($self->{'Contents'})!~/Array$/) {
            $self->{'Contents'} = PDFArray($self->{'Contents'});
    }
}

sub addcontent {
    my ($self,@objs) = @_;
        $self->fixcontents;
        $self->{'Contents'}->add_elements(@objs);
}
sub precontent {
    my ($self,@objs) = @_;
    $self->fixcontents;
    unshift(@{$self->{'Contents'}->val},@objs);
}

sub gfx {
    use PDF::API2::Gfx;
    my ($self,$dir) = @_;
    my $gfx=PDF::API2::Gfx->new();
    if(defined($dir) && $dir>0) {
        $self->precontent($gfx);
    } else {
        $self->addcontent($gfx);
    }
    $self->{' apipdf'}->new_obj($gfx);
    $gfx->{' apipdf'}=$self->{' apipdf'};
    $gfx->{' apipage'}=$self;
    $gfx->compress() if($self->{' api'}->{forcecompress});
    return($gfx);
}

=item $txt = $page->text

Returns a text content object.

=cut

sub text {
    use PDF::API2::Text;
    my ($self,$dir) = @_;
    my $text=PDF::API2::Text->new();
    if(defined($dir) && $dir>0) {
        $self->precontent($text);
    } else {
        $self->addcontent($text);
    }
    $self->{' apipdf'}->new_obj($text);
    $text->{' apipdf'}=$self->{' apipdf'};
    $text->{' apipage'}=$self;
    $text->compress() if($self->{' api'}->{forcecompress});
    return($text);
}

=item $hyb = $page->hybrid

Returns a hybrid content object.

=cut

sub hybrid {
    use PDF::API2::Hybrid;
    my ($self,$dir) = @_;
    my $hyb=PDF::API2::Hybrid->new();
    if(defined($dir) && $dir>0) {
        $self->precontent($hyb);
    } else {
        $self->addcontent($hyb);
    }
    $self->{' apipdf'}->new_obj($hyb);
    $hyb->{' apipdf'}=$self->{' apipdf'};
    $hyb->{' apipage'}=$self;
    $hyb->compress() if($self->{' api'}->{forcecompress});
    return($hyb);
}

=item $ant = $page->annotation

Returns a annotation object.

=cut

sub annotation {
    use PDF::API2::Annotation;
    my ($self, $type, $key, $obj) = @_;
        $self->{'Annots'}||=PDFArray();
        $self->update if(ref($self->{'Annots'})=~/Objind/);
        $self->{'Annots'}->realise if(ref($self->{'Annots'})=~/Objind/);
    my $ant=PDF::API2::Annotation->new;
        $self->{'Annots'}->add_elements($ant);
        $self->{' apipdf'}->new_obj($ant);
        $ant->{' apipdf'}=$self->{' apipdf'};
        $ant->{' apipage'}=$self;
        return($ant);
}

=item $page->resource $type, $key, $obj

Adds a resource to the page-inheritance tree.

B<Example:>

    $co->resource('Font',$fontkey,$fontobj);
    $co->resource('XObject',$imagekey,$imageobj);
    $co->resource('Shading',$shadekey,$shadeobj);
    $co->resource('ColorSpace',$spacekey,$speceobj);

B<Note:> You only have to add the required resources, if
they are NOT handled by the *font*, *image*, *shade* or *space*
methods.

=cut

sub resource {
    my ($self, $type, $key, $obj, $force) = @_;
    my ($dict) = $self->find_prop('Resources');

    $dict= $dict || $self->{Resources} || PDFDict();

    $dict->realise if(ref($dict)=~/Objind$/);

    $dict->{$type}=$dict->{$type} || PDFDict();
    $dict->{$type}->realise if(ref($dict->{$type})=~/Objind$/);

  unless(defined $obj) {
    return($dict->{$type}->{$key} || undef);
  } else {
    if($force) {
        $dict->{$type}->{$key}=$obj;
    } else {
        $dict->{$type}->{$key}=$dict->{$type}->{$key} || $obj;
    }
  
    $self->{' apipdf'}->out_obj($dict)
        if($dict->is_obj($self->{' apipdf'}));
  
    $self->{' apipdf'}->out_obj($dict->{$type})
        if($dict->{$type}->is_obj($self->{' apipdf'}));
  
    $self->{' apipdf'}->out_obj($obj)
        if($obj->is_obj($self->{' apipdf'}));
  
          $self->{' apipdf'}->out_obj($self);
  
    return($dict);
  }
}

sub content {
    my ($self,$obj,$dir) = @_;
    if(defined($dir) && $dir>0) {
        $self->precontent($obj);
    } else {
        $self->addcontent($obj);
    }
    $self->{' apipdf'}->new_obj($obj) unless($obj->is_obj($self->{' apipdf'}));
    $obj->{' apipdf'}=$self->{' apipdf'};
    $obj->{' apipage'}=$self;
    return($obj);
}

=item $pie = $page->piechart @options

Returns a pie-chart object (see PDF::API2::Chart::Pie for details).

=cut

sub piechart {
    use PDF::API2::Chart::Pie;
    my $self = shift @_;
    my $pie=PDF::API2::Chart::Pie->new(@_);
  $self->content($pie);
  $pie->compress() if($self->{' api'}->{forcecompress});
  return($pie);
}

sub ship_out
{
    my ($self, $pdf) = @_;

    $pdf->ship_out($self);
    if (defined $self->{'Contents'})
    { $pdf->ship_out($self->{'Contents'}->elementsof); }
    $self;
}

sub outobjdeep {
    my ($self, @opts) = @_;
    foreach my $k (qw/ api apipdf /) {
        $self->{" $k"}=undef;
        delete($self->{" $k"});
    }
    $self->SUPER::outobjdeep(@opts);
}

1;

__END__

=head1 AUTHOR

alfred reibenschuh

=cut
