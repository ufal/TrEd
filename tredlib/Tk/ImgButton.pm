# Copyright (c) 2004 Petr Pajas. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Tk::ImgButton;

use vars qw($VERSION);
$VERSION = '0.1'; # $Id$

use base  qw(Tk::Button);
use Tk::widgets qw(Frame Label Image);

Construct Tk::Widget 'ImgButton';

sub InitObject
{
 require Tk::Button;
 # LabeledEntry constructor.
 #
 my($cw, $args) = @_;
 print "ImgButton\n";
 print join",",keys %$args,"\n";
 my $img  = delete $args->{-image};
 my $text = delete $args->{-text};
 my $pad = delete $args->{-pad};
 my $underline = delete $args->{-underline};
 $cw->SUPER::InitObject($args);
 # Advertised subwidgets:  entry.
 my $i = $cw->Label(-image => $img);
 my $t = $cw->Label(-text => $text, (defined($underline) ? (-underline => $underline) : ()) );
 $i->pack('-padx' => (defined($pad) ? $pad : 5), '-side' => 'left', '-expand' => 1, '-fill' => 'both');
 $t->pack('-side' => 'left', '-expand' => 1, '-fill' => 'both');
 $cw->ConfigSpecs('-image' => [$i]);

 for my $w ($i,$t) {
   for (qw(ButtonPress Button
	   ButtonRelease  FocusIn Motion
	   FocusOut KeyPress Key
	   KeyRelease Enter  Leave   Activate Deactivate)) {
     $w->bind($_,sub{});
   }
 }

}

1;
