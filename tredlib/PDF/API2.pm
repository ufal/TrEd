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
package PDF::API2;

BEGIN {
    use vars qw( $VERSION $hasWeakRef $seq);
    ( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:43 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;
    eval " use WeakRef; ";
    $hasWeakRef= $@ ? 0 : 1;
    $seq="AA";
}


=head1 PDF::API2

=head1 NAME

PDF::API2 - The Next Generation API for creating and modifing PDFs.

=head1 SYNOPSIS

    use PDF::API2;

    $pdf = PDF::API2->new;
    $pdf = PDF::API2->open('some.pdf');
    $page = $pdf->page;
    $page = $pdf->openpage($pagenum);
    $img = $pdf->image('some.jpg');
    $font = $pdf->corefont('Times-Roman');
    $font = $pdf->psfont('Times-Roman.pfb','Times-Roman.afm');
    $font = $pdf->ttfont('TimesNewRoman.ttf');

=cut

require 5.006;

use PDF::API2::PDF::FileAPI;
use PDF::API2::PDF::Page;
use PDF::API2::PDF::Utils;
use PDF::API2::PDF::TTFont;
use PDF::API2::PDF::TTFont0;

use PDF::API2::Util;
use PDF::API2::CoreFont;
use PDF::API2::Page;
use PDF::API2::IOString;
use PDF::API2::PSFont;
use PDF::API2::TrueTypeFont;
use PDF::API2::Image;
use PDF::API2::PdfImage;
use PDF::API2::Pattern;
use PDF::API2::ColorSpace;
use PDF::API2::Barcode;
use PDF::API2::ExtGState;
use PDF::API2::Outlines;
use Compress::Zlib;

use Math::Trig;

use POSIX qw( ceil floor );

=head1 METHODS

=head2 PDF::API2

=over 4

=item $pdf = PDF::API->new %opts

Creates a new pdf-file object. If you know beforehand
to save the pdf to file you can give the '-file' option,
to minimize possible memory requirements.

B<Example:>

    $pdf = PDF::API2->new();

    $pdf = PDF::API2->new(-file => 'ournew.pdf');

=cut

sub new {
    my $class=shift(@_);
    my %opt=@_;
    my $self={};
    bless($self,$class);
    $self->{pdf}=PDF::API2::PDF::FileAPI->new();
    $self->{time}='_'.pdfkey(time());
#   foreach my $para (keys(%opt)) {
#       $self->{$para}=$opt{$para};
#   }
    $self->{pdf}->{' version'} = 4;
    $self->{pages} = PDF::API2::PDF::Pages->new($self->{pdf});
    weaken($self->{pages}) if($hasWeakRef);
    $self->{pages}->proc_set(qw( PDF Text ImageB ImageC ImageI ));
    $self->{pages}->{Resources}||=PDFDict();
    $self->{pdf}->new_obj($self->{pages}->{Resources}) unless($self->{pages}->{Resources}->is_obj($self->{pdf}));
    $self->{catalog}=$self->{pdf}->{Root};
    weaken($self->{catalog}) if($hasWeakRef);
    $self->{pagestack}=[];
    my $dig=digest16(digest32($class,$self,%opt));
        $self->{pdf}->{'ID'}=PDFArray(PDFStr($dig),PDFStr($dig));
        $self->{pdf}->{' id'}=$dig;
        $self->{forcecompress}= ($^O eq 'os390') ? 0 : 1;
        $self->preferences(%opt);
    if($opt{-file}) {
        $self->{' filed'}=$opt{-file};
        $self->{pdf}->create_file($opt{-file});
    }
    $self->info( 'Producer' => "PDF::API2 incarnation=$VERSION OS=$^O" );
    return $self;
}

=item $pdf->preferences %opts

Controls viewing=preferences for the pdf.

B<Options:>

    -fullscreen ... Full-screen mode, with no menu bar, window controls, or any other window visible.
    -thumbs ... Thumbnail images visible.
    -outlines ... Document outline visible.
    -singlepage ... Display one page at a time.
    -onecolumn ... Display the pages in one column.
    -twocolumnleft ... Display the pages in two columns, with oddnumbered pages on the left.
    -twocolumnrigth ... Display the pages in two columns, with oddnumbered pages on the right.
    -hidetoolbar ... Specifying whether to hide tool bars.
    -hidemenubar ... Specifying whether to hide menu bars.
    -hidewindowui ... Specifying whether to hide user interface elements.
    -fitwindow ... Specifying whether to resize the document’s window to the size of the displayed page.
    -centerwindow ... Specifying whether to position the document’s window in the center of the screen.
    -displaytitle ... Specifying whether the window’s title bar should display the document title
            taken from the Title entry of the document information dictionary.
    -afterfullscreenthumbs ... Thumbnail images visible after Full-screen mode.
    -afterfullscreenoutlines ... Document outline visible after Full-screen mode.

    -firstpage => [ $pageobj, %opts] ... Specifying the page to be displayed,
            plus one of the following options:

        -fit => 1

        Display the page designated by page, with its contents magnified just enough to
        fit the entire page within the window both horizontally and vertically. If the
        required horizontal and vertical magnification factors are different, use the
        smaller of the two, centering the page within the window in the other dimension.

        -fith => $top

        Display the page designated by page, with the vertical coordinate top positioned
        at the top edge of the window and the contents of the page magnified just enough
        to fit the entire width of the page within the window.

        -fitv => $left

        Display the page designated by page, with the horizontal coordinate left positioned
        at the left edge of the window and the contents of the page magnified just enough
        to fit the entire height of the page within the window.

        -fitr => [ $left, $bottom, $right, $top ]

        Display the page designated by page, with its contents magnified just enough to
        fit the rectangle specified by the coordinates left, bottom, right, and top
        entirely within the window both horizontally and vertically. If the required
        horizontal and vertical magnification factors are different, use the smaller of
        the two, centering the rectangle within the window in the other dimension.

        -fitb => 1

        Display the page designated by page, with its contents magnified just enough
        to fit its bounding box entirely within the window both horizontally and
        vertically. If the required horizontal and vertical magnification factors are
        different, use the smaller of the two, centering the bounding box within the
        window in the other dimension.

        -fitbh => $top

        Display the page designated by page, with the vertical coordinate top
        positioned at the top edge of the window and the contents of the page
        magnified just enough to fit the entire width of its bounding box
        within the window.

        -fitbv => $left

        Display the page designated by page, with the horizontal coordinate
        left positioned at the left edge of the window and the contents of the page
        magnified just enough to fit the entire height of its bounding box within the
        window.

        -xyz => [ $left, $top, $zoom ]

        Display the page designated by page, with the coordinates (left, top) positioned
        at the top-left corner of the window and the contents of the page magnified by
        the factor zoom. A zero (0) value for any of the parameters left, top, or zoom
        specifies that the current value of that parameter is to be retained unchanged.


B<Example:>

    $pdf->preferences(
        -fullscreen => 1,
        -onecolumn => 1,
        -afterfullscreenoutlines => 1,
        -firstpage => [ $pageobj , -fit => 1],
    );

=cut

sub preferences {
    my $self=shift @_;
    my %opt=@_;
    if($opt{-fullscreen}) {
        $self->{catalog}->{PageMode}=PDFName('FullScreen');
    } elsif($opt{-thumbs}) {
        $self->{catalog}->{PageMode}=PDFName('UseThumbs');
    } elsif($opt{-outlines}) {
        $self->{catalog}->{PageMode}=PDFName('UseOutlines');
    } else {
        $self->{catalog}->{PageMode}=PDFName('UseNone');
    }
    if($opt{-singlepage}) {
        $self->{catalog}->{PageLayout}=PDFName('SinglePage');
    } elsif($opt{-onecolumn}) {
        $self->{catalog}->{PageLayout}=PDFName('OneColumn');
    } elsif($opt{-twocolumnleft}) {
        $self->{catalog}->{PageLayout}=PDFName('TwoColumnLeft');
    } elsif($opt{-twocolumnrigth}) {
        $self->{catalog}->{PageLayout}=PDFName('TwoColumnRight');
    } else {
        $self->{catalog}->{PageLayout}=PDFName('SinglePage');
    }

    $self->{catalog}->{ViewerPreferences}||=PDFDict();
    $self->{catalog}->{ViewerPreferences}->realise;

    if($opt{-hidetoolbar}) {
        $self->{catalog}->{ViewerPreferences}->{HideToolbar}=PDFBool(1);
    }
    if($opt{-hidemenubar}) {
        $self->{catalog}->{ViewerPreferences}->{HideMenubar}=PDFBool(1);
    }
    if($opt{-hidewindowui}) {
        $self->{catalog}->{ViewerPreferences}->{HideWindowUI}=PDFBool(1);
    }
    if($opt{-fitwindow}) {
        $self->{catalog}->{ViewerPreferences}->{FitWindow}=PDFBool(1);
    }
    if($opt{-centerwindow}) {
        $self->{catalog}->{ViewerPreferences}->{CenterWindow}=PDFBool(1);
    }
    if($opt{-displaytitle}) {
        $self->{catalog}->{ViewerPreferences}->{DisplayDocTitle}=PDFBool(1);
    }
    if($opt{-righttoleft}) {
        $self->{catalog}->{ViewerPreferences}->{Direction}=PDFName("R2L");
    }

    if($opt{-afterfullscreenthumbs}) {
        $self->{catalog}->{ViewerPreferences}->{NonFullScreenPageMode}=PDFName('UseThumbs');
    } elsif($opt{-afterfullscreenoutlines}) {
        $self->{catalog}->{ViewerPreferences}->{NonFullScreenPageMode}=PDFName('UseOutlines');
    } else {
        $self->{catalog}->{ViewerPreferences}->{NonFullScreenPageMode}=PDFName('UseNone');
    }

    if($opt{-firstpage}) {
        my ($page,%o)=@{$opt{-firstpage}};

        $o{-fit}=1 if(scalar(keys %o)<1);

        if(defined $o{-fit}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('Fit'));
        } elsif(defined $o{-fith}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitH'),PDFNum($o{-fith}));
        } elsif(defined $o{-fitb}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitB'));
        } elsif(defined $o{-fitbh}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitBH'),PDFNum($o{-fitbh}));
        } elsif(defined $o{-fitv}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitV'),PDFNum($o{-fitv}));
        } elsif(defined $o{-fitbv}) {
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitBV'),PDFNum($o{-fitbv}));
        } elsif(defined $o{-fitr}) {
            die "insufficient parameters to -fitr => [] " unless(scalar @{$o{-fitr}} == 4);
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('FitR'),map {PDFNum($_)} @{$o{-fitr}});
        } elsif(defined $o{-xyz}) {
            die "insufficient parameters to -xyz => [] " unless(scalar @{$o{-xyz}} == 3);
            $self->{catalog}->{OpenAction}=PDFArray($page,PDFName('XYZ'),map {PDFNum($_)} @{$o{-xyz}});
        }
    }
    $self->{pdf}->out_obj($self->{catalog});

    return $self;
}

sub proc_pages {
    my ($pdf, $pgs) = @_;
    my ($pg, $pgref, @pglist);

    if(defined($pgs->{Resources})) {
        eval {
            $pgs->{Resources}->realise;
        };
    }
    foreach $pgref ($pgs->{'Kids'}->elementsof) {
        $pg = $pdf->read_obj($pgref);
        if ($pg->{'Type'}->val =~ m/^Pages$/o) {
            push(@pglist, proc_pages($pdf, $pg));
        } else {
            $pdf->{' apipagecount'}++;
            $pgref->{' pnum'} = $pdf->{' apipagecount'};
            if(defined($pg->{Resources})) {
                eval {
                    $pg->{Resources}->realise;
                };
            }
            weaken($pgref) if($hasWeakRef);
            push (@pglist, $pgref);
        }
    }
    return(@pglist);
}

=item $pdf = PDF::API->open $pdffile

Opens an existing PDF.

=cut

sub open {
    my $class=shift(@_);
    my $file=shift(@_);
    my %opt=@_;
    my $self={};
    bless($self,$class);
    $self->default('Compression',1);
    $self->default('subset',1);
    $self->default('update',1);
    foreach my $para (keys(%opt)) {
        $self->default($para,$opt{$para});
    }
    die "File '$file' does not exist." unless(-f $file);
    my $fh=PDF::API2::IOString->new();
    $fh->import_from_file($file);
    $self->{pdf}=PDF::API2::PDF::FileAPI->open($fh,1);

#   $self->{pdf}=PDF::API2::PDF::FileAPI->open($file,1);

    $self->{pdf}->{' fname'}=$file;
    $self->{pdf}->{'Root'}->realise;
    $self->{pages}=$self->{pdf}->{'Root'}->{'Pages'}->realise;
    weaken($self->{pages}) if($hasWeakRef);
    $self->{pdf}->{' version'} = 3;
    $self->{pdf}->{' apipagecount'} = 0;
    my @pages=proc_pages($self->{pdf},$self->{pages});
    $self->{pagestack}=[sort {$a->{' pnum'} <=> $b->{' pnum'}} @pages];
    $self->{catalog}=$self->{pdf}->{Root};
    $self->{reopened}=1;
    $self->{time}='_'.pdfkey(time());
    my $dig=digest16(digest32($class,$file,%opt));
    if(defined $self->{pdf}->{'ID'}){
        $self->{pdf}->{'ID'}->realise;
        $self->{pdf}->{' id'}=$self->{pdf}->{'ID'}->val->[0]->val;
        $self->{pdf}->{'ID'}=PDFArray(PDFStr($self->{pdf}->{' id'}),PDFStr($dig));
    } else {
        $self->{pdf}->{'ID'}=PDFArray(PDFStr($dig),PDFStr($dig));
        $self->{pdf}->{' id'}=$dig;
    }
        $self->{forcecompress}= ($^O eq 'os390') ? 0 : 1;
    return $self;
}

=item $page = $pdf->page

=item $page = $pdf->page $index

Returns a new page object or inserts-and-returns a new page at $index.

B<Note:> on $index

    -1 ... is inserted before the last page
    1 ... is inserted before page number 1
    0 ... is simply appended

=cut

sub page {
    my $self=shift;
    my $index=shift || 0;
    my $page;
    if($index==0) {
        $page=PDF::API2::Page->new($self->{pdf},$self->{pages});
    } else {
        $page=PDF::API2::Page->new($self->{pdf},$self->{pages},$index);
    }
    $page->{' apipdf'}=$self->{pdf};
    weaken($page->{' apipdf'}) if($hasWeakRef);
    $page->{' api'}=$self;
    weaken($page->{' api'}) if($hasWeakRef);
    $self->{pdf}->out_obj($page);
    $self->{pdf}->out_obj($self->{pages});
    if($index==0) {
        push(@{$self->{pagestack}},$page);
    } elsif($index<0) {
        splice(@{$self->{pagestack}},$index,0,$page);
    } else {
        splice(@{$self->{pagestack}},$index-1,0,$page);
    }
    $page->{Resources}=$self->{pages}->{Resources};
    return $page;
}

=item $pageobj = $pdf->openpage $index

Returns the pageobject of page $index.

B<Note:> on $index

    -1,0 ... returns the last page
    1 ... returns page number 1

=cut

sub openpage {
    my $self=shift @_;
    my $index=shift @_||0;
    my ($page,$rotate,$media,$trans);

    if($index==0) {
        $page=$self->{pagestack}->[-1];
    } elsif($index<0) {
        $page=$self->{pagestack}->[$index];
    } else {
        $page=$self->{pagestack}->[$index-1];
    }
    if(ref($page) ne 'PDF::API2::Page') {
        $page=PDF::API2::Page->coerce($self->{pdf},$page);
        $self->{pdf}->out_obj($page);
        if($index==0) {
            $self->{pagestack}->[-1]=$page;
        } elsif($index<0) {
            $self->{pagestack}->[$index]=$page;
        } else {
            $self->{pagestack}->[$index-1]=$page;
        }
        if(($rotate=$page->find_prop('Rotate')) && (!defined($page->{' fixed'}) || $page->{' fixed'}<1)) {
          $rotate=($rotate->val+360)%360;

      if($rotate!=0) {
        $page->{Rotate}=PDFNum(0);
        foreach my $mediatype (qw( MediaBox CropBox BleedBox TrimBox ArtBox )) {
            if($media=$page->find_prop($mediatype)) {
              $media=[ map{ $_->val } $media->elementsof ];
            } else {
            $media=[0,0,612,792];
            next if($mediatype ne 'MediaBox');
            }
              if($rotate==90) {
                $trans="0 -1 1 0 0 $media->[2] cm" if($mediatype eq 'MediaBox');
                $media=[$media->[1],$media->[0],$media->[3],$media->[2]];
              } elsif($rotate==180) {
                $trans="-1 0 0 -1 $media->[2] $media->[3] cm" if($mediatype eq 'MediaBox');
              } elsif($rotate==270) {
                $trans="-1 0 0 -1 $media->[3] 0 cm" if($mediatype eq 'MediaBox');
                $media=[$media->[1],$media->[0],$media->[3],$media->[2]];
              }
            $page->{$mediatype}=PDFArray(map { PDFNum($_) } @{$media});
        }

      } else {
            $trans="";
        }
          
      } else {
        $trans="";
      }

        if(defined $page->{Contents} && (!defined($page->{' fixed'}) || $page->{' fixed'}<1) ) {
            $page->fixcontents;
            my $uncontent=$page->{Contents};
            delete $page->{Contents};
            my $content=$page->hybrid();
            $content->add(" $trans ");
            # we already have a 'q' in the hybrid stream ## $content->{' stream'}="\n q \n";
            foreach my $k ($uncontent->elementsof) {
                $k->realise;
                $content->{' stream'}.=" ".unfilter($k->{Filter}, $k->{' stream'})." ";
            }
            ## $content->{Length}=PDFNum(length($content->{' stream'}));
            # this  will be fixed by the following code or content or filters 
            
            ## if we like compress we will do it now to do quicker saves
            if($self->{forcecompress}>0){
            $content->{' stream'}.="\n Q \n";
                $content->compress;
                $content->{' stream'}=dofilter($content->{Filter}, $content->{' stream'});
                $content->{' nofilt'}=1;
                $content->{Length}=PDFNum(length($content->{' stream'}));
            }
            $page->{' fixed'}=1;
        }
    }

  $self->{pdf}->out_obj($page);
  $self->{pdf}->out_obj($self->{pages});
    $page->{' api'}=$self;
    weaken($page->{' api'}) if($hasWeakRef);
    $page->{' reopened'}=1;
    return($page);
}

=item $pageobj = $pdf->clonepage $sourceindex, $targetindex

Returns the pageobject of page $targetindex, cloned from $sourceindex.

B<Note:> on $index

    -1,0 ... returns the last page
    1 ... returns page number 1

B<Beware:>

Under some circumstances, this method may cause $pdf->update to die.
These circumstances remain unresolved but previously generated pdfs
via API2 remain unaffected so far.

=cut

sub clonepage {
    my $self=shift @_;
    my $s_idx=shift @_||0;
    my $t_idx=shift @_||0;
    $t_idx=0 if($self->pages<$t_idx);
    my ($s_page,$t_page);

    $s_page=$self->openpage($s_idx);
    $t_page=$self->page($t_idx);

    $s_page->copy($self->{pdf},$t_page);

####################################################################
        if(defined($t_page->{Resources})) {
                $t_page->{Resources}->realise if($t_page->{Resources}->is_obj($self->{pdf}));
                $t_page->{Resources}=$t_page->{Resources}->copy($self->{pdf});
        ##      $self->{pdf}->new_obj($t_page->{Resources});
                $t_page->{Resources}->{' realised'}=1;
        }

        if(defined($t_page->{Contents})) {
        $t_page->fixcontents;
        $s_page->fixcontents;
    #   foreach my $content ($t_page->{Contents}->elementsof) {
    #       $content->realise;
    #   }
    #
    #   my $tempobj=$t_page->{Contents};
    #
        #        $t_page->{Contents}=$t_page->{Contents}->copy;
    #   $self->{pdf}->remove_obj($tempobj);

        #        foreach my $content ($t_page->{Contents}->elementsof) {
        #                $self->{pdf}->new_obj($content);
        #        }

        $t_page->{Contents}->{' val'}=[];
        $t_page->{Contents}->add_elements($s_page->{Contents}->elementsof);
        }
####################################################################
    delete $t_page->{' reopened'};

        $self->{pdf}->out_obj($t_page);
        $self->{pdf}->out_obj($self->{pages});
    return($t_page);
}

# $target_object = walk_obj $obj_cache, $source_pdf, $target_pdf, $source_object [, @keys_to_copy ]

sub walk_obj {
    my ($objs,$spdf,$tpdf,$obj,@keys)=@_;

    my $tobj;


    if(ref($obj)=~/Objind$/) {
        $obj->realise;
    }

    return($objs->{scalar $obj}) if(defined $objs->{scalar $obj});
##  die "infinite loop while copying objects" if($obj->{' copied'});
    $tobj=$obj->copy;
##  $obj->{' copied'}=1;
    $tpdf->new_obj($tobj) if($obj->is_obj($spdf));

    $objs->{scalar $obj}=$tobj;

    if(ref($obj)=~/Array$/) {
        $tobj->{' val'}=[];
        foreach my $k ($obj->elementsof) {
            $k->realise if(ref($k)=~/Objind$/);
            $tobj->add_elements(walk_obj($objs,$spdf,$tpdf,$k));
        }
    } elsif(ref($obj)=~/Dict$/) {
        @keys=keys(%{$tobj}) if(scalar @keys <1);
        foreach my $k (@keys) {
            next if($k=~/^ /);
            next unless(defined($obj->{$k}));
            $tobj->{$k}=walk_obj($objs,$spdf,$tpdf,$obj->{$k});
        }
        if($obj->{' stream'}) {
            if($tobj->{Filter}) {
                $tobj->{' nofilt'}=1;
            } else {
                delete $tobj->{' nofilt'};
                $tobj->{Filter}=PDFArray(PDFName('FlateDecode'));
            }
            $tobj->{' stream'}=$obj->{' stream'};
        }
    }
    delete $tobj->{' streamloc'};
    delete $tobj->{' streamsrc'};
    return($tobj);
}

=item $pageobj = $pdf->importpage $sourcepdf, $sourceindex, $targetindex

Returns the pageobject of page $targetindex, imported from $sourcepdf,$sourceindex.

B<Note:> on $index

    -1,0 ... returns the last page
    1 ... returns page number 1

B<Note:> you can specify a page object instead as $targetindex
so that the contents of the sourcepage will be 'merged into'.

=cut

sub importpage {
    my $self=shift @_;
    my $s_pdf=shift @_;
    my $s_idx=shift @_||0;
    my $t_idx=shift @_||0;
    my ($s_page,$t_page);

    if(ref($s_idx) eq 'PDF::API2::Page') {
        $s_page=$s_idx;
    } else {
        $s_page=$s_pdf->openpage($s_idx);
    }

    if(ref($t_idx) eq 'PDF::API2::Page') {
        $t_page=$t_idx;
    } else {
        $t_idx=0 if($self->pages<$t_idx);
        $t_page=$self->page($t_idx);
    }

    $self->{apiimportcache}=$self->{apiimportcache}||{};
    $self->{apiimportcache}->{$s_pdf}=$self->{apiimportcache}->{$s_pdf}||{};

    foreach my $k (qw( MediaBox ArtBox TrimBox BleedBox CropBox Rotate )) {
        next unless(defined $s_page->{$k});
        $t_page->{$k} = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k});
    }
    if($t_page!=$t_idx) {
        foreach my $k (qw( B Dur Hid Trans AA PieceInfo LastModified SeparationInfo ID PZ )) {
            next unless(defined $s_page->{$k});
            $t_page->{$k} = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k});
        }
    }

    my %resmod=();
    foreach my $k (qw( Resources )) {
        $s_page->{$k}=$s_page->find_prop($k);
        next unless(defined $s_page->{$k});
        $s_page->{$k}->realise if(ref($s_page->{$k})=~/Objind$/);

        $t_page->{$k}||=PDFDict();
        foreach my $sk (qw( XObject ExtGState Font ProcSet Properties )) {
            next unless(defined $s_page->{$k}->{$sk});
            $s_page->{$k}->{$sk}->realise if(ref($s_page->{$k}->{$sk})=~/Objind$/);
            $t_page->{$k}->{$sk}||=PDFDict();
            foreach my $ssk (keys %{$s_page->{$k}->{$sk}}) {
                next if($ssk=~/^ /);
                # my $nssk=$PDF::API2::seq.$ssk;
                # $resmod{$ssk}=$nssk;
                # $t_page->{$k}->{$sk}->{$nssk} = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k}->{$sk}->{$ssk});
                # $PDF::API2::seq++;
                $t_page->{$k}->{$sk}->{$ssk} = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k}->{$sk}->{$ssk});
            }
        }
        foreach my $sk (qw( ColorSpace Pattern Shading )) {
            next unless(defined $s_page->{$k}->{$sk});
            $s_page->{$k}->{$sk}->realise if(ref($s_page->{$k}->{$sk})=~/Objind$/);
            $t_page->{$k}->{$sk}||=PDFDict();
            foreach my $ssk (keys %{$s_page->{$k}->{$sk}}) {
                next if($ssk=~/^ /);
                $t_page->{$k}->{$sk}->{$ssk} = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k}->{$sk}->{$ssk});
            }
        }
    }

    # create a whole content stream
    ## technically it is possible to submit an unfinished 
    ## (eg. newly created) source-page, but thats non-sense,
    ## so we expect a page fixed by openpage and die otherwise
    die "page not processed via openpage ... " unless($s_page->{' fixed'}==1);
    my $content=$t_page->hybrid();

  # since the source page comes from openpage it may already 
  # contains the required starting 'q' without the final 'Q'
  # if forcecompress is in effect
    if(defined $s_page->{Contents}) {
        $s_page->fixcontents;
        
    $content->{' stream'}="q\n";
    # openpage pages only contain one stream
        my ($k)=$s_page->{Contents}->elementsof;
        $k->realise;
        if($k->{' nofilt'}) {
          # we have a finished stream here 
          # so we unfilter
          $content->{' stream'}.=unfilter($k->{Filter}, $k->{' stream'});
        } else {
          # stream is an unfinished/unfiltered hybrid
          # so we just copy it
            $content->{' stream'}=$k->{' stream'};
        }
      # and modify resources
       # foreach my $r (keys %resmod) {
       #     $content->{' stream'}=~s/\/$r(\x0a|\x0d|\s+)/\/$resmod{$r}$1/gm;
       # }
        if($k->{' nofilt'} && $self->{forcecompress}>0) {
        # standardize filters and refilter
      # since forcecompress was in effect
            $content->add('Q');
            $content->compress;
          $content->{' stream'}=dofilter($content->{Filter}, $content->{' stream'});
          $content->{' nofilt'}=1;
      $content->{Length}=PDFNum(length($content->{' stream'}));
        } else {
          # unfinished hybrid (do nothing)
        }
    }
    ## if we like compress we will do it now to do quicker saves
    if($self->{forcecompress}>0 && $content->{' nofilt'}<0){
        # since we compress the stream without
        # calling back at the content/.. methods
        # which corrrect the streams Q's we have 
        # to add them here
        $content->compress;
        $content->add('Q');
        $content->{' stream'}=dofilter($content->{Filter}, $content->{' stream'});
        $content->{' nofilt'}=1;
        $content->{Length}=PDFNum(length($content->{' stream'}));
    }

        # copy annotations and/or form elements as well
        if (exists $s_page->{Annots} and $s_page->{Annots}) {

                # first set up the AcroForm, if required
                my $AcroForm;
                if (my $a = $s_pdf->{pdf}->{Root}->realise->{AcroForm}) {
                        $a->realise;
                #        $AcroForm = PDFDict;
                #        # keys from PDF Reference 1.4 (table 8.47)
                #        my @done = qw(Fields); # doing later
                #        foreach my $k (qw(Fields NeedAppearances SigFlags CO DR DA Q)) {
                #                next if grep $_ eq $k , @done;
                #                push @done,$k;
                #                next unless defined $a->{$k};
                #                $AcroForm->{$k} = 
                #        }
                        $AcroForm = walk_obj({},$s_pdf->{pdf},$self->{pdf},$a,qw( NeedAppearances SigFlags CO DR DA Q ));
                }
                my @Fields = ();
                my @Annots = ();
                foreach my $a ($s_page->{Annots}->elementsof) {
                        $a->realise;
                        my $t_a = PDFDict;
                        $self->{pdf}->new_obj($t_a);
                        # these objects are likely to be both annotations and Acroform fields
                        # key names are copied from PDF Reference 1.4 (Tables)
                        my @k = (
                                qw( Type Subtype Contents P Rect NM M F BS Border
                                        AP AS C CA T Popup A AA StructParent
                                ), # Annotations - Common (8.10)
                                qw( Subtype Contents Open Name ), # Text Annotations (8.15)
                                qw( Subtype Contents Dest H PA ), # Link Annotations (8.16)
                                qw( Subtype Contents DA Q ), # Free Text Annotations (8.17)
                                qw( Subtype Contents L BS LE IC ) , # Line Annotations (8.18)
                                qw( Subtype Contents BS IC ), # Square and Circle Annotations (8.20)
                                qw( Subtype Contents QuadPoints ), # Markup Annotations (8.21)
                                qw( Subtype Contents Name ), # Rubber Stamp Annotations (8.22)
                                qw( Subtype Contents InkList BS ), # Ink Annotations (8.23)
                                qw( Subtype Contents Parent Open ), # Popup Annotations (8.24)
                                qw( Subtype FS Contents Name ), # File Attachment Annotations (8.25)
                                qw( Subtype Sound Contents Name ), # Sound Annotations (8.26)
                                qw( Subtype Movie Contents A ), # Movie Annotations (8.27)
                                qw( Subtype Contents H MK ), # Widget Annotations (8.28)
                                # Printers Mark Annotations (none)
                                # Trap Network Annotations (none)
                        );
                        push @k, (
                                qw( Subtype FT Parent Kids T TU TM Ff V DV AA ), # Fields - Common (8.49)
                                qw( DR DA Q ), # Fields containing variable text (8.51)
                                qw( Opt ), # Checkbox field (8.54)
                                qw( Opt ), # Radio field (8.55)
                                qw( MaxLen ), # Text field (8.57)
                                qw( Opt TI I ), # Choice field (8.59)
                        ) if $AcroForm;
                        # sorting out dups
                        my %ky=map { $_ => 1 } @k;
                        # we do P separately, as it points to the page the Annotation is on
                        delete $ky{P};
                        # copy everything else
                        foreach my $k (keys %ky) {
                                next unless defined $a->{$k};
                                $t_a->{$k} = walk_obj({},$s_pdf->{pdf},$self->{pdf},$a->{$k});
                        }
                        $t_a->{P} = $t_page;
                        push @Annots, $t_a;
                        push @Fields, $t_a if ($AcroForm and $t_a->{Subtype}->val eq 'Widget');
                }
                $t_page->{Annots} = PDFArray(@Annots);
                $AcroForm->{Fields} = PDFArray(@Fields) if $AcroForm;
                $self->{pdf}->{Root}->{AcroForm} = $AcroForm;
        }

        $t_page->{' imported'} = 1;

    $self->{pdf}->out_obj($t_page);
    $self->{pdf}->out_obj($self->{pages});
    $self->{pdf}->out_obj($self->{pages}->{Resources});
    $self->{pdf}->out_obj($content);
    if(wantarray) {
        return($content,$t_page);
    } else {
        return($t_page);
    }
}

=item $pagenumber = $pdf->pages

Returns the number of pages in the document.

=cut

sub pages {
    my $self=shift @_;
    return scalar @{$self->{pagestack}};
}

=item $pdf->mediabox $w, $h

=item $pdf->mediabox $llx, $lly, $urx, $ury

Sets the global mediabox.

=cut

sub mediabox {
    my ($self,$x1,$y1,$x2,$y2) = @_;
    if(defined $x2) {
        $self->{pages}->{'MediaBox'}=PDFArray(
            map { PDFNum(float($_)) } ($x1,$y1,$x2,$y2)
        );
    } else {
        $self->{pages}->{'MediaBox'}=PDFArray(
            map { PDFNum(float($_)) } (0,0,$x1,$y1)
        );
    }
    $self;
}

=item $pdf->update

Updates a previously "opened" document after all changes have been applied.

=cut

sub update {
    my $self=shift @_;
    $self->saveas($self->{pdf}->{' fname'});
}

=item $pdf->saveas $file

Saves the document.

=cut

sub saveas {
    my ($self,$file)=@_;
    if($self->{reopened}) {
        $self->{pdf}->append_file;
        CORE::open(OUTF,">$file");
        binmode(OUTF);
        print OUTF ${$self->{pdf}->{' OUTFILE'}->string_ref};
        CORE::close(OUTF);
    } elsif($self->{' filed'}) {
        $self->{pdf}->close_file;
    } else {
        $self->{pdf}->out_file($file);
    }
    $self->end;
}

sub save {
    my ($self,$file)=@_;
    if($self->{reopened}) {
        die "invalid method invokation: use 'saveas' instead.";
    } elsif($self->{' filed'}) {
        $self->{pdf}->close_file;
    } else {
        die "invalid method invokation: use 'saveas' instead.";
    }
    $self->end;
}

sub save_xml {
    my ($self,$file)=@_;
    my $fh=IO::File->new;
    $fh->open("> $file");
    $self->{pdf}->save_xml($fh);
    $fh->close;
    $self->end;
}


=item $string = $pdf->stringify

Returns the document in a string.

=cut

sub stringify {
    my ($self)=@_;
    my $str;
    if((defined $self->{reopened}) && ($self->{reopened}==1)) {
        $self->{pdf}->append_file;
        $str=${$self->{pdf}->{' OUTFILE'}->string_ref};
    } else {
        my $fh = PDF::API2::IOString->new();
        $fh->open();
        eval {
            $self->{pdf}->out_file($fh);
        };
        $str=${$fh->string_ref};
        $fh->realclose;
    }
    $self->end;
    return($str);
}

sub release { $_[0]->end; return(undef);}

=item $pdf->end

Destroys the document.

=cut

sub end {
    my $self=shift(@_);
    $self->{pdf}->release if(defined($self->{pdf}));

        foreach my $key (keys %{$self})
        {
            $self->{$key}=undef;
            delete ($self->{$key});
        }

    undef;
}

=item %infohash $pdf->info %infohash

Sets/Gets the info structure of the document.

B<Example:>

    $pdf->info(
        'Author'       => " Alfred Reibenschuh ",
        'CreationDate' => "D:20020911000000+01'00'",
        'ModDate'      => "D:YYYYMMDDhhmmssOHH'mm'",
        'Creator'      => "fredos-script.pl",
        'Producer'     => "PDF::API2",
        'Title'        => "some Publication",
        'Subject'      => "perl ?",
        'Keywords'     => "all good things are pdf"
    );

=cut

sub info {
    my $self=shift @_;
    my %opt=@_;

    if(!defined($self->{pdf}->{'Info'})) {
            $self->{pdf}->{'Info'}=PDFDict();
            $self->{pdf}->new_obj($self->{'pdf'}->{'Info'});
    } else {
        $self->{pdf}->{'Info'}->realise;
    }

    if(scalar @_) {
      foreach (qw(  Author CreationDate ModDate Creator Producer Title Subject Keywords  )) {
        next unless(defined $opt{$_});
        $self->{pdf}->{'Info'}->{$_}=PDFStr($opt{$_}||'') 
      }
    $self->{pdf}->out_obj($self->{pdf}->{'Info'});
    }
        

    if(defined $self->{pdf}->{'Info'}) {
      %opt=();
      foreach (qw(  Author CreationDate ModDate Creator Producer Title Subject Keywords  )) {
        next unless(defined $self->{pdf}->{'Info'}->{$_});
        $opt{$_}=$self->{pdf}->{'Info'}->{$_}->val; 
      }
  }
  return(%opt);
}

=item $pdf->finishobjects @objects

Force objects to be written to file.

=cut

sub finishobjects {
    my ($self,@objs)=@_;
    if($self->{reopened}) {
        die "invalid method invokation: no file, use 'saveas' instead.";
    } elsif($self->{' filed'}) {
        $self->{pdf}->ship_out(@objs);
    } else {
        die "invalid method invokation: no file, use 'saveas' instead.";
    }
}

=item $val = $pdf->default $parameter

=item $pdf->default $parameter, $val

Gets/Sets default values for the behaviour of ::API2.

=cut

sub default {
    my ($self,$parameter,$var)=@_;
    $parameter=~s/[^a-zA-Z\d]//g;
    $parameter=lc($parameter);
    my $temp=$self->{$parameter};
    if(defined $var) {
        $self->{$parameter}=$var;
    }
    return($temp);
}

=item $font = $pdf->corefont $fontname [, %options]

Returns a new or existing adobe core font object.

B<Examples:>

    $font = $pdf->corefont('Times-Roman');
    $font = $pdf->corefont('Times-Bold');
    $font = $pdf->corefont('Helvetica');
    $font = $pdf->corefont('ZapfDingbats');

=cut

sub corefont {
    my ($self,$name,@opts)=@_;

  my $pkey='cFx'.pdfkey($name).((scalar @opts >0) ? '-'.pdfkey(@opts) : '0');

    my $obj;
    
    if($obj=$self->resource('Font',$pkey)) {
      return($obj);
    } else {
      $obj=PDF::API2::CoreFont->new_api($self,$name,@opts);
    }
    
    my $key=$obj->{' apiname'};
  
    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $self->resource('Font',$key,$obj);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $font = $pdf->psfont $pfbfile,$afmfile

Returns a new or existing adobe type1 font object.

B<Examples:>

    $font = $pdf->psfont('Times-Book.pfb','Times-Book.afm');
    $font = $pdf->psfont('/fonts/Synest-FB.pfb','/fonts/Synest-FB.afm');
    $font = $pdf->psfont('../Highland-URW.pfb','../Highland-URW.afm');

=cut

sub psfont {
    my ($self,$pfb,$afm,$encoding,@glyphs)=@_;
    my $key='PSx'.pdfkey(($pfb||'x').($afm||'y'),$encoding);

    my $obj;
    
    if($obj=$self->resource('Font',$key)) {
      return($obj);
    }

  $obj=PDF::API2::PSFont->new($self->{pdf},$pfb,$afm,$key,$encoding,@glyphs);
  $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $obj->{' apiname'}=$key;
    $obj->{' apipdf'}=$self->{pdf};
    weaken($obj->{' apipdf'}) if($hasWeakRef);
        $obj->{' api'}=$self;
    weaken($obj->{' api'}) if($hasWeakRef);

    $self->resource('Font',$key,$obj,$self->{reopened});

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $font = $pdf->ttfont $ttfile [, %options]

Returns a new or existing truetype font object.

B<Examples:>

    $font = $pdf->ttfont('TimesNewRoman.ttf');
    $font = $pdf->ttfont('/fonts/Univers-Bold.ttf');
    $font = $pdf->ttfont('../Democratica-SmallCaps.ttf');



=cut

sub ttfont {
    my ($self,$file,@opts)=@_;

    $self->{ttfonts}||={};
    my $obj=$self->{ttfonts}->{join(':',$file,@opts)} || PDF::API2::TrueTypeFont->new_api($self,$file,@opts);
    $self->{ttfonts}->{join(':',$file,@opts)}=$obj;
    return($obj);
}

=item $font = $pdf->synfont $fontobj [, %options]

Creates a new 'synthetic variant' of the given font.

Valid options are: '-slant', '-oblique' and '-bold'.

Valid range for '-slant' is 0.5-1.5
(values are width-factor).

Valid range for '-oblique' is 5-25, with 12-15 yielding best results
(values are degrees).

Valid range for '-bold' is 2-6 with 4.2-5.5 yielding best results
(values are tens of em of the design-size, which is per-mille).

Whats 'synthetic variant' anyhow ? It's 'poor mans multiple-master' !

B<Examples:>

    $tt = $pdf->corefont('Helvetica-Bold');
    $font = $pdf->synfont($tt, -slant => 0.65 );
    # yields 'Helvetica-Bold' at 65% char-width

    $tt = $pdf->ttfont('../Democratica-SmallCaps.ttf');
    $font = $pdf->synfont($tt, -bold => 4.5 );
    # yields 'Democratica-SmallCaps' 

    $tt = $pdf->psfont('./HelveNew.pfb','./HelveNew.afm');
    $font = $pdf->synfont($tt, -oblique => 13 );

    $tt = $pdf->corefont('Helvetica');
    $font = $pdf->synfont($tt, -slant => 0.65, -oblique => 15, -bold => 4.3 );


=cut

sub synfont {
    my ($self,$font,@opts)=@_;

    $self->{synfonts}||={};
    my $obj=$self->{synfonts}->{join(':',$font,@opts)} || PDF::API2::SynFont->new_api($self,$font,@opts);
    $self->{synfonts}->{join(':',$font,@opts)}=$obj;
    return($obj);
}

=item $img = $pdf->image $file

Returns a new image object from a file or a GD::Image object.

B<Examples:>

    $img = $pdf->image('yetanotherfun.jpg');
    $img = $pdf->image('truly24bitpic.png');
    $img = $pdf->image('reallargefile.pnm');

    $gdimgobj=GD::Image->newFromPng('truly24bitpic.png');
    $img = $pdf->image($gdimgobj);

B<Important Note:>

This is an unmaintained function, please use one of the following
for proper support: image_jpeg, image_png, image_gd, image_pnm.

=cut

sub image {
    my ($self,$file,@opts)=@_;
        my $obj=PDF::API2::Image->new($self->{pdf},$file,$self->{time},@opts);
    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));
    if($obj->{SMask}) {
        $self->{pdf}->new_obj($obj->{SMask}) unless($obj->{SMask}->is_obj($self->{pdf}));
    }

#   $obj->{' apipdf'}=$self->{pdf};
#   $obj->{' api'}=$self;

    $self->resource('XObject',$obj->{' apiname'},$obj,1);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $img = $pdf->image_jpeg $file

Returns a new image object from a jpeg-file.

B<Examples:>

    $img = $pdf->image_jpeg('yetanotherfun.jpg');

=cut

sub image_jpeg {
    my ($self,$file,%opts)=@_;
    my $objname='JPEGx'.pdfkey($file.time());
    my $obj;
    if($obj=$self->resource('XObject',$objname)) {
      return($obj);
    }
    $obj=PDF::API2::Image->new_jpeg($self->{pdf},$objname,$file);
    $obj->{' apiname'}=$objname;

    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $self->resource('XObject',$obj->{' apiname'},$obj,1);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $img = $pdf->image_png $file

Returns a new image object from a png-file.

B<Examples:>

    $img = $pdf->image_png('yetanotherfun.png');

=cut

sub image_png {
    my ($self,$file,%opts)=@_;
    my $objname='PNGx'.pdfkey($file.time());
    my $obj;
    if($obj=$self->resource('XObject',$objname)) {
      return($obj);
    }
    $obj=PDF::API2::Image->new_png($self->{pdf},$objname,$file);
    $obj->{' apiname'}=$objname;

    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $self->resource('XObject',$obj->{' apiname'},$obj,1);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

#=item $img = $pdf->image_gif $file
#
#Returns a new image object from a gif-file.
#
#B<Examples:>
#
#   $img = $pdf->image_gif('yetanotherfun.gif');
#
#=cut
#
#sub image_gif {
#   my ($self,$file,%opts)=@_;
#   my $objname='GIFx'.pdfkey($file.time());
#   my $obj=PDF::API2::Image->new_gif($self->{pdf},$objname,$file);
#   $obj->{' apiname'}=$objname;
#
#   $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));
#
#   $self->resource('XObject',$obj->{' apiname'},$obj,1);
#
#   $self->{pdf}->out_obj($self->{pages});
#   return($obj);
#}

=item $img = $pdf->image_tiff $file

Returns a new image object from a tiff-file.

B<Examples:>

    $img = $pdf->image_tiff('yetanotherfun.TIF');

B<Please Note:>

Currently supported are any combination of the following tiff-features:
white-is-zero, black-is-zero, rgb, palette, cmyk, packbits, ccittfax g3-1d,
ccittfax g4, lzw and flate, as-long-as the image is not striped !!!

=cut

sub image_tiff {
    my ($self,$file,%opts)=@_;
    my $objname='TIFFx'.pdfkey($file.time());
    my $obj;
    if($obj=$self->resource('XObject',$objname)) {
      return($obj);
    }
    $obj=PDF::API2::Image->new_tiff($self->{pdf},$objname,$file);
    $obj->{' apiname'}=$objname;

    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $self->resource('XObject',$obj->{' apiname'},$obj,1);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $img = $pdf->image_pnm $file

Returns a new image object from a portable anymap (aka. netpbm).

B<Examples:>

    $img = $pdf->image_pnm('yetanotherfun.pbm');
    $img = $pdf->image_pnm('yetanotherfun.pgm');
    $img = $pdf->image_pnm('yetanotherfun.ppm');

=cut

sub image_pnm {
    my ($self,$file,%opts)=@_;
    my $objname='PNMx'.pdfkey($file.time());
    my $obj;
    if($obj=$self->resource('XObject',$objname)) {
      return($obj);
    }
    $obj=PDF::API2::Image->new_pnm($self->{pdf},$objname,$file);
    $obj->{' apiname'}=$objname;

    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $self->resource('XObject',$obj->{' apiname'},$obj,1);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $img = $pdf->pdfimage $file, $page_number

Returns a new image object,
which is actually a page from another pdf.

B<Examples:>

    $img = $pdf->pdfimage('test1.pdf',1);
    $img = $pdf->pdfimage('another-test.pdf',2);
    $img = $pdf->pdfimage('really-large.pdf',1000);

=item $img = $pdf->pdfimageobj $pdfobj, $page_number

As $pdf->pdfimage, but takes an already opened pdfobject (API2->open) as parameter.

B<Note:> This is functionally the same as the one above, but far less
resource-intensive, if you use many pages (possible the same) from one single pdf.

=cut


sub pdfimageobj {
    my $self=shift @_;
    my $s_pdf=shift @_;
    my $s_idx=shift @_||0;
    my ($s_page,$t_page);

    $s_page=$s_pdf->openpage($s_idx);
    $t_page=PDF::API2::PdfImage->new();

    $self->{apiimportcache}=$self->{apiimportcache}||{};
    $self->{apiimportcache}->{$s_pdf}=$self->{apiimportcache}->{$s_pdf}||{};

    my $dict = $s_page->find_prop('CropBox')||$s_page->find_prop('MediaBox');
    if(defined $dict) {
        my ($lx,$ly,$rx,$ry)=$dict->elementsof;
        $t_page->{LX}=PDFNum($lx->val);
        $t_page->{' lx'}=$lx->val;
        $t_page->{LY}=PDFNum($ly->val);
        $t_page->{' ly'}=$ly->val;
        $t_page->{RX}=PDFNum($rx->val);
        $t_page->{' rx'}=$rx->val;
        $t_page->{RY}=PDFNum($ry->val);
        $t_page->{' ry'}=$ry->val;
    }
    $k='Resources';
    $s_page->{$k}=$s_page->find_prop($k);
    $s_page->{$k}->realise if(ref($s_page->{$k})=~/Objind$/);
    my %resmod=();
    if(defined $s_page->{$k}) {
        $t_page->{$k}=PDFDict();
        foreach my $sk (qw( XObject ExtGState Font ProcSet Properties )) {
            next unless(defined $s_page->{$k}->{$sk});
            $s_page->{$k}->{$sk}->realise if(ref($s_page->{$k}->{$sk})=~/Objind$/);
            $t_page->{$k}->{$sk}||=PDFDict();
            foreach my $ssk (keys %{$s_page->{$k}->{$sk}}) {
                next if($ssk=~/^ /);
                my $nssk=$PDF::API2::seq."+$ssk";
                $resmod{$ssk}=$nssk;
                $t_page->{$k}->{$sk}->{$nssk} = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k}->{$sk}->{$ssk});
                $PDF::API2::seq++;
            }
        }
        foreach my $sk (qw( ColorSpace Pattern Shading )) {
            next unless(defined $s_page->{$k}->{$sk});
            $s_page->{$k}->{$sk}->realise if(ref($s_page->{$k}->{$sk})=~/Objind$/);
            $t_page->{$k}->{$sk}||=PDFDict();
            foreach my $ssk (keys %{$s_page->{$k}->{$sk}}) {
                next if($ssk=~/^ /);
                $t_page->{$k}->{$sk}->{$ssk} = walk_obj($self->{apiimportcache}->{$s_pdf},$s_pdf->{pdf},$self->{pdf},$s_page->{$k}->{$sk}->{$ssk});
            }
        }
    }



    if(defined $s_page->{Contents}) {
        $s_page->fixcontents;
        foreach my $k ($s_page->{Contents}->elementsof) {
            $k->realise if(ref($k)=~/Objind$/);

            $t_page->{' pdfimage'}.=" q ".unfilter($k->{'Filter'},$k->{' stream'})." Q ";
        }
    }
    foreach my $r (keys %resmod) {
        $t_page->{' pdfimage'}=~s/\/$r(\x0a|\x0d|\s+)/\/$resmod{$r}$1/gm;
    }

    $self->{pdf}->new_obj($t_page) unless($t_page->is_obj($self->{pdf}));
    $self->{pdf}->out_obj($self->{pages});

    return($t_page);
}

sub pdfimage {
    my $self=shift @_;
    my $s_pdf=shift @_;
    my $s_idx=shift @_||0;

    $s_pdf=PDF::API2->open($s_pdf);
    my $t_page=$self->pdfimageobj($s_pdf,$s_idx);
    $s_pdf->end;

    return($t_page);
}

=item $shadeing = $pdf->shade

Returns a new shading object.

=cut

sub shade {
    my ($self,%opts)=@_;
    my $key='SHx'.pdfkey(%opts || 'shade'.localtime() );
    my $obj=PDFDict();
#   my $pat=$self->pattern(-type=>2);
    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $obj->{' apiname'}=$key;
    $obj->{' apipdf'}=$self->{pdf};
    weaken($obj->{' apipdf'}) if($hasWeakRef);
        $obj->{' api'}=$self;
    weaken($obj->{' api'}) if($hasWeakRef);

    $self->resource('Shading',$key,$obj,1);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $pat = $pdf->pattern

Returns a new pattern object.

=cut

sub pattern {
    my ($self,%opts)=@_;
    my $obj=PDF::API2::Pattern->new();
    my $key=$obj->{' apiname'};
    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

#   $obj->{' apipdf'}=$self->{pdf};
#   $obj->{' api'}=$self;

    $self->resource('Pattern',$key,$obj,1);

    $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item $cs = $pdf->colorspace %parameters

Returns a new colorspace object.

B<Examples:>

    $cs = $pdf->colorspace(
        -type => 'CalRGB',
        -whitepoint => [ 0.9, 1, 1.1 ],
        -blackpoint => [ 0, 0, 0 ],
        -gamma => [ 2.2, 2.2, 2.2 ],
        -matrix => [
            0.41238, 0.21259, 0.01929,
            0.35757, 0.71519, 0.11919,
            0.1805,  0.07217, 0.95049
        ]
    );

    $cs = $pdf->colorspace(
        -type => 'CalGray',
        -whitepoint => [ 0.9, 1, 1.1 ],
        -blackpoint => [ 0, 0, 0 ],
        -gamma => 2.2
    );

    $cs = $pdf->colorspace(
        -type => 'Lab',
        -whitepoint => [ 0.9, 1, 1.1 ],
        -blackpoint => [ 0, 0, 0 ],
        -gamma => [ 2.2, 2.2, 2.2 ],
        -range => [ -100, 100, -100, 100 ]
    );

    $cs = $pdf->colorspace(
        -type => 'Indexed',
        -base => 'DeviceRGB',
        -maxindex => 3,
        -whitepoint => [ 0.9, 1, 1.1 ],
        -blackpoint => [ 0, 0, 0 ],
        -gamma => [ 2.2, 2.2, 2.2 ],
        -colors => [
            [ 0,0,0 ],  # black = 0
            [ 1,1,1 ],  # white = 1
            [ 1,0,0 ],  # red = 2
            [ 0,0,1 ],  # blue = 3
        ]
    );

    $cs = $pdf->colorspace(
        -type => 'ICCBased',
        -base => 'DeviceRGB',
        -components => 3,
        -iccfile => 'codacus.icc'
    );

=cut

sub colorspace {
    my ($self,@opt)=@_;
    my $key='CSx'.pdfkey('colorspace',@opt);
    my $obj=PDF::API2::ColorSpace->new($self->{pdf},$key,@opt);
    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $obj->{' apiname'}=$key;
#   $obj->{' apipdf'}=$self->{pdf};
#       $obj->{' api'}=$self;

    $self->resource('ColorSpace',$key,$obj,1);

        $self->{pdf}->out_obj($self->{pages});
    return($obj);
}

=item @color = $pdf->businesscolor $basecolor [, $lightdark ]

=item @color = $pdf->businesscolor $colornumber [, $lightdark ]

Returns a color-array suitible for use with the stroke/fillcolor methods.

=cut

sub businesscolor {
    my $self=shift @_;
    my @col;
#   $self->{bccs} = $self->{bccs} || $self->colorspace(
#       -type => 'CalRGB',
#       -whitepoint => [ 0.9505, 1, 1.089 ],
#       -blackpoint => [ 0, 0, 0 ],
#       -gamma => [ 2.2, 2.2, 2.2 ],
#       -matrix => [
#           0.41238, 0.21259, 0.01929,
#           0.35757, 0.71519, 0.11919,
#           0.1805,  0.07217, 0.95049
#       ]
#   );
    my $color=shift @_||0;
    my $ld=shift @_||0;
    if($color=~/^[a-z\!\$\%\&\#]+/) {
        @col=namecolor($color);
        my ($hue)=RGBtoHSV( @col );
        @col=HSLtoRGB($hue,1,0.5+($ld/10));
    } else {
        $color-=1;
        if($color<0) {
            @col=(0.5+($ld/10),0.5+($ld/10),0.5+($ld/10));
        } else {
            @col=HSLtoRGB($color*30,1,0.5+($ld/10));
        }
    }
#   return($self->{bccs},@col);
    return(RGBasCMYK(@col));
}

=item $img = $pdf->barcode %options

Returns a new barcode object.

B<Note:> refer to PDF::API2::Barcode for more details.

=cut

sub barcode {
    my ($self,%opts)=@_;
    my $key='BCx'.pdfkey('barcode'.time().rand(0x7fffff));
    my $obj=PDF::API2::Barcode->new($key,%opts);
    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));

    $obj->{' apiname'}=$key;
    $obj->{' apipdf'}=$self->{pdf};
    weaken($obj->{' apipdf'}) if($hasWeakRef);
    $obj->{' api'}=$self;
    weaken($obj->{' api'}) if($hasWeakRef);

    $self->resource('XObject',$key,$obj,1);

        $self->{pdf}->out_obj($self->{pages});
    $obj->compress() if($self->{forcecompress});
    return($obj);
}

=item $egs = $pdf->extgstate

Returns a new extended-graphics-state object.

=cut

sub extgstate {
    my ($self)=@_;
    my $key='XTGSx'.pdfkey('extgstate'.time().rand(0x7fffff));
    my $obj=PDF::API2::ExtGState->new($self->{pdf},$key);
    $self->{pdf}->new_obj($obj) unless($obj->is_obj($self->{pdf}));
    $self->resource('ExtGState',$key,$obj,1);
        $obj->{' api'}=$self;
    weaken($obj->{' api'}) if($hasWeakRef);
    return($obj);
}


=item $otls = $pdf->outlines

Returns a new or existing outlines object.

=cut

sub outlines {
    my ($self)=@_;

    $self->{pdf}->{Root}->{Outlines}||=PDF::API2::Outlines->new($self);
    
    my $obj=$self->{pdf}->{Root}->{Outlines};

    $self->{pdf}->new_obj($obj) if(!$obj->is_obj($self->{pdf}));
    $self->{pdf}->out_obj($obj);
    $self->{pdf}->out_obj($self->{pdf}->{Root});

    return($obj);

}

=item $page->resource $type, $key, $obj, $force

Adds a resource to the global page-inheritance tree.

B<Example:>

    $pdf->resource('Font',$fontkey,$fontobj);
    $pdf->resource('XObject',$imagekey,$imageobj);
    $pdf->resource('Shading',$shadekey,$shadeobj);
    $pdf->resource('ColorSpace',$spacekey,$speceobj);

B<Note:> You only have to add the required resources, if
they are NOT handled by the *font*, *image*, *shade* or *space*
methods.

=cut

sub resource {
    my ($self, $type, $key, $obj, $force) = @_;

    $self->{pages}->{Resources}||=PDFDict();

    my $dict=$self->{pages}->{Resources};
    $dict->realise if(ref($dict)=~/Objind$/);
    
    $self->{pdf}->new_obj($dict) unless($dict->is_obj($self->{pdf}));

    $dict->{$type}=$dict->{$type} || PDFDict();
    $dict->{$type}->realise if(ref($dict->{$type})=~/Objind$/);

  unless(defined($obj)) {
    return($dict->{$type}->{$key} || undef);
  } else {
    if($force) {
        $dict->{$type}->{$key}=$obj;
    } else {
        $dict->{$type}->{$key}=$dict->{$type}->{$key} || $obj;
    }
  
    $self->{pdf}->out_obj($dict)
        if($dict->is_obj($self->{pdf}));
  
    $self->{pdf}->out_obj($dict->{$type})
        if($dict->{$type}->is_obj($self->{pdf}));
  
    $self->{pdf}->out_obj($obj)
        if($obj->is_obj($self->{pdf}));
  
          $self->{pdf}->out_obj($self->{pages});
  
    return($dict);
  }
}

1;

__END__

=back

=head1 AUTHOR

alfred reibenschuh

=cut
