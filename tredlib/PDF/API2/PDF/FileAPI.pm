package PDF::API2::PDF::FileAPI;

use strict;
no strict "refs";
use vars qw($cr %types $VERSION @ISA);
no warnings qw(uninitialized);

use IO::File;

use PDF::API2::PDF::Utils;
use PDF::API2::PDF::Array;
use PDF::API2::PDF::Bool;
use PDF::API2::PDF::Dict;
use PDF::API2::PDF::Name;
use PDF::API2::PDF::Number;
use PDF::API2::PDF::Objind;
use PDF::API2::PDF::String;
use PDF::API2::PDF::File 0.19;
use PDF::API2::TTF::Font 0.28;

@ISA=qw( PDF::API2::PDF::File );

( $VERSION ) = '$Revisioning: 0.40_01                   Mon Jul 14 12:56:45 2003 $' =~ /\$Revisioning:\s+([^\s]+)/;

BEGIN
{
    my ($t, $type);
    
    $cr = '\s*(?:\015|\012|(?:\015\012))';
    %types = (
            'Page' => 'PDF::API2::PDF::Page',
            'Pages' => 'PDF::API2::PDF::Pages'
    );
    
    foreach $type (keys %types)
    {
        $t = $types{$type};
        $t =~ s|::|/|og;
        require "$t.pm";
    }
}

sub open
{
    my ($class, $fname, $update) = @_;
    my ($self, $buf, $xpos, $end, $tdict, $k);
    my ($fh);

    $self = $class->_new;
    if (ref $fname)
    { 
        $self->{' INFILE'} = $fname; 
        if ($update)
        {
            $self->{' update'} = 1;
            $self->{' OUTFILE'} = $fname;
        }
        $fh = $fname; 
    }
    else
    {
    	die "File '$fname' does not exist !" unless(-f $fname);
        $fh = IO::File->new(($update ? "+" : "") . "<$fname") || return undef;
        $self->{' INFILE'} = $fh;
        binmode $fh;
        if ($update)
        {
            $self->{' update'} = 1;
            $self->{' OUTFILE'} = $fh;
            $self->{' fname'} = $fname;
        }
    }
    $fh->seek(0, 0);            # go to start of file
    $fh->read($buf, 255);
    if ($buf !~ m/^\%PDF\-1\.\d+\s*$cr/mo)
    { die "$fname not a PDF file version 1.x"; }

    $fh->seek(0, 2);            # go to end of file
    $end = $fh->tell();
    $self->{' epos'} = $end;
    $fh->seek($end - 1024, 0);
    $fh->read($buf, 1024);
    if ($buf !~ m/startxref$cr\s*([0-9]+)$cr\%\%eof.*?$/oi)
    { die "Malformed PDF file $fname"; }
    $xpos = $1;
    
    $tdict = $self->readxrtr($xpos, $self);
    foreach $k (keys %{$tdict})
    { $self->{$k} = $tdict->{$k}; }
    return $self;
}


sub release
{
    my ($self,$explicitDestruct) = @_;

    my @tofree = values %{$self};
    map { $self->{$_}=undef; delete $self->{$_}; } keys %{$self};
    while (my $item = shift @tofree)
    {
        if (UNIVERSAL::can($item,'release'))
        {
            $item->release(1);
        }
        elsif (ref($item) eq 'ARRAY')
        {
            push( @tofree, @{$item} );
        }
        elsif (ref($item) eq 'HASH')
        {
            push( @tofree, values %{$item} );
            map { $item->{$_}=undef; delete $item->{$_}; } keys %{$item};
        }
        else
        {
        	$item=undef;
        }
    }
}

sub append_file
{
    my ($self) = @_;
    my ($tdict, $fh, $t, $buf, $ver);
    
    return undef unless ($self->{' update'});

    $fh = $self->{' INFILE'};
    
    # hack to upgrade pdf-version number to support
    # requested features in higher versions that
    # the pdf was originally created.
    $fh->seek(7,0);
    $fh->read($buf, 3);
    $buf=~s/[^\d]+$//g;
    $ver=$self->{' version'} || 2;
    if($buf < $ver) {
    ##	print STDERR "files version was 1.$buf upgraded to 1.$ver.\n";
	    $fh->seek(0,0);
	    $fh->print("%PDF-1.$ver\n");
    }
    
    $tdict = PDFDict();
    $tdict->{'Prev'} = PDFNum($self->{' loc'});
    $tdict->{'Info'} = $self->{'Info'};
    if (defined $self->{' newroot'})
    { $tdict->{'Root'} = $self->{' newroot'}; }
    else
    { $tdict->{'Root'} = $self->{'Root'}; }
    $tdict->{'Size'} = $self->{'Size'};

    foreach $t (grep ($_ !~ m/^\s/o, keys %$self))
    { $tdict->{$t} = $self->{$t} unless defined $tdict->{$t}; }

    $fh->seek($self->{' epos'}, 0);
    $self->out_trailer($tdict,$self->{' update'});
    close($self->{' OUTFILE'});
}

sub save_xml
{
    my ($self,$fh) = @_;
    my ($tdict, $t, $buf, $ver);
    
    $fh->print("<Pdf>\n");
    
    $tdict = PDFDict();
    $tdict->{'Prev'} = PDFNum($self->{' loc'}) if ($self->{' loc'});
    $tdict->{'Size'} = $self->{'Size'} || PDFNum(1);
    $tdict->{'Info'} = $self->{'Info'};
    if (defined $self->{' newroot'})
    { $tdict->{'Root'} = $self->{' newroot'}; }
    else
    { $tdict->{'Root'} = $self->{'Root'}; }
    $tdict->{'Size'} = $self->{'Size'};

    foreach $t (grep ($_ !~ m/^\s/o, keys %$self))
    { $tdict->{$t} = $self->{$t} unless defined $tdict->{$t}; }

    $self->out_xml($tdict,$fh);
    $fh->print("</Pdf>\n");
}

sub ship_xml
{
    my ($self, $fh, @objs) = @_;
    my ($n, $objind, $i, $j);
    my ($objnum, $objgen);

    @objs = @{$self->{' outlist'}} unless (scalar @objs > 0);
    foreach $objind (@objs)
    {
        next unless $objind->is_obj($self);
        $j = -1;
        for ($i = 0; $i < scalar @{$self->{' outlist'}}; $i++)
        {
            if ($self->{' outlist'}[$i] eq $objind)
            {
                $j = $i;
                last;
            }
        }
        next if ($j < 0);
        splice(@{$self->{' outlist'}}, $j, 1);
        delete $self->{' outlist_cache'}{$objind};
        next if grep {$_ eq $objind} @{$self->{' free'}};

        ($objnum, $objgen) = @{$self->{' objects'}{$objind->uid}}[0..1];
        $fh->printf("<Object id=\"%d %d\">\n", $objnum, $objgen);
        $objind->outxmldeep($fh, $self, 'objnum' => $objnum, 'objgen' => $objgen,-xmlfh=>$fh);
        $fh->print("</Object>\n");

        # Note that we've output this obj, not forgetting to update the cache
        # of whats printed.
        unless (exists $self->{' printed_cache'}{$objind})
        {
            push( @{$self->{' printed'}}, $objind );
            $self->{' printed_cache'}{$objind}++;
        }
    }
    $self;
}

sub out_xml
{
    my ($self, $tdict, $fh) = @_;
    my ($objind, $j, $i, $iend, @xreflist, $first, $k, $xref, $tloc, @freelist);
    my (%locs, $size);

    while (@{$self->{' outlist'}})
    { $self->ship_xml($fh); }

#    $tdict->{'Size'} = PDFNum($self->{' maxobj'});
#
#    $tloc = $fh->tell;
#    $fh->print("xref\n");
#
#    @xreflist = sort {$self->{' objects'}{$a->uid}[0] <=>
#                $self->{' objects'}{$b->uid}[0]}
#                        (@{$self->{' printed'}}, @{$self->{' free'}});
#
#    unless ($update)
#    {
#        $i = 1;
#        for ($j = 0; $j < @xreflist; $j++)
#        {
#            my (@inserts);
#            $k = $xreflist[$j];
#            while ($i < $self->{' objects'}{$k->uid}[0])
#            {
#                my ($n) = PDF::API2::PDF::Objind->new();
#                $self->add_obj($n, $i, 0);
#                $self->free_obj($n);
#                push(@inserts, $n);
#                $i++;
#            }
#            splice(@xreflist, $j, 0, @inserts);
#            $j += @inserts;
#            $i++;
#        }
#    }
#
#    @freelist = sort {$self->{' objects'}{$a->uid}[0] <=>
#                $self->{' objects'}{$b->uid}[0]} @{$self->{' free'}};
#    
#    $j = 0; $first = -1; $k = 0;
#    for ($i = 0; $i <= $#xreflist + 1; $i++)
#    {
#        if ($i == 0)
#        {
#            $first = $i; $j = $xreflist[0]->{' objnum'};
#            $fh->printf("0 1\n%010d 65535 f \n", $ff);
#        }
#        if ($i > $#xreflist || $self->{' objects'}{$xreflist[$i]->uid}[0] != $j + 1)
#        {
#            $fh->print(($first == -1 ? "0 " : "$self->{' objects'}{$xreflist[$first]->uid}[0] ") . ($i - $first) . "\n");
#            if ($first == -1)
#            {
#                $fh->printf("%010d 65535 f \n", defined $freelist[$k] ? $self->{' objects'}{$freelist[$k]->uid}[0] : 0);
#                $first = 0;
#            }
#            for ($j = $first; $j < $i; $j++)
#            {
#                $xref = $xreflist[$j];
#                if (defined $freelist[$k] && defined $xref && "$freelist[$k]" eq "$xref")
#                {
#                    $k++;
#                    $fh->print(pack("A10AA5A4",
#                            sprintf("%010d", (defined $freelist[$k] ?
#                                    $self->{' objects'}{$freelist[$k]->uid}[0] : 0)), " ",
#                            sprintf("%05d", $self->{' objects'}{$xref->uid}[1] + 1),
#                            " f \n"));
#                } else
#                {
#                    $fh->print(pack("A10AA5A4", sprintf("%010d", $self->{' locs'}{$xref->uid}), " ",
#                            sprintf("%05d", $self->{' objects'}{$xref->uid}[1]),
#                            " n \n"));
#                }
#            }
#            $first = $i;
#            $j = $self->{' objects'}{$xreflist[$i]->uid}[0] if ($i < scalar @xreflist);
#        } else
#        { $j++; }
#    }
#    $fh->print("trailer\n");
#    $tdict->outobjdeep($fh, $self);
#    $fh->print("\nstartxref\n$tloc\n" . '%%EOF' . "\n");
}


1;
